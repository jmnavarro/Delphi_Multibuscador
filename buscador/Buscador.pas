//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//
// Unidad: Buscador.pas
//
// Propósito:
//    Se implementa un componente no visual (heredado de TComponent) que realiza una serie de 
//    búsquedas simultaneas utilizando programación multi-hilo.
//    El componente se puede registrar incluyéndolo en un paquete, o bien crearlo dinamicamente.
//
// Autor:          Salvador Jover (www.sjover.com) y JM (www.lawebdejm.com)
// Fecha:          01/07/2003
// Observaciones:  Unidad creada en Delphi 5
// Copyright:      Este código es de dominio público y se puede utilizar y/o mejorar siempre que
//                 SE HAGA REFERENCIA AL AUTOR ORIGINAL, ya sea a través de estos comentarios
//                 o de cualquier otro modo.
//
//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
unit Buscador;

interface


uses classes, windows, HiloBusqueda, SysUtils, syncobjs;


type
   //
   // TBusqueda: representa una búsqueda
   //
   TBusqueda = class(TObject)
   private
      FRuta: string;
      FSubcarpetas: boolean;
   public
      constructor Create(ARuta: string; ASubcarpetas: boolean);
   published
      property Ruta: string read FRuta write FRuta;
      property Subcarpetas: boolean read FSubcarpetas write FSubcarpetas; 
   end;


   //
   // Componente "Buscador"
   //

   // excepciones
   ESinRutas = class(Exception);
   EBuscando = class(Exception);

   // estados posibles del buscador
   TEstadoBuscador  = (ebInactivo, ebBuscando, ebPausado, ebCancelado);
   TEstadosBuscador = set of TEstadoBuscador;

   TBuscador = class; // forward

   // definición de los eventos
   TOnEncontrado  = procedure(Sender: TThread; archivo: string; index: integer) of object;
   TOnFinHilo     = procedure(Sender: TThread; TotalEncontrado: integer) of object;
   TOnFinBusqueda = procedure(Sender: TBuscador) of object;


   TBuscador = class(TComponent)
   private
      FRutas: TStrings;

      FEstado: TEstadosBuscador;

      FResultado: TStrings; // lista de resultados
      FHilos: TListaHilos;  // lista de hilos activos

      // eventos del componente
      FOnEncontrado:  TOnEncontrado;
      FOnFinHilo:     TOnFinHilo;
      FOnFinBusqueda: TOnFinBusqueda;

      procedure CrearBusquedas;

      // lanzamiento de eventos del componente
      procedure CallOnEncontrado(hilo: THiloBusqueda; ind: integer);
      procedure CallOnFinHilo(hilo: THiloBusqueda);
      procedure CallOnFinBusqueda;

      // eventos del hilo
      procedure OnHiloEncontrado(hilo: THiloBusqueda; ruta: string);
      procedure OnHiloTerminate(Sender: TObject);

      // getters/setters
      function GetPausado: boolean;
      procedure SetPausado(value: boolean);

      procedure SetRutas(value: TStrings);

   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      function AddRuta(ruta: string; subcarpetas: boolean): Integer;

      procedure Execute;
      procedure Cancel;

      property Estado: TEstadosBuscador read FEstado;
      property Pausado: boolean read GetPausado write SetPausado;
      property Resultado: TStrings read FResultado;

   published
      property Rutas: TStrings read FRutas write SetRutas;

      // eventos
      property OnEncontrado:  TOnEncontrado  read FOnEncontrado  write FOnEncontrado;
      property OnFinHilo:     TOnFinHilo     read FOnFinHilo     write FOnFinHilo;
      property OnFinBusqueda: TOnFinBusqueda read FOnFinBusqueda write FOnFinBusqueda;
   end;

procedure Register;


implementation

uses forms;


procedure Register;
begin
   RegisterComponents('JM', [TBuscador]);
end;

{class TBusqueda}

//
// TBusqueda
//


//  Proc/Fun     : constructor Create
//
//  Valor retorno: vacío
//  Parametros   : ARuta: string; ASubcarpetas: boolean
//
//  Comentarios  : Contructor de la clase TBusqueda. Esta clase encapsulta los
//                 datos minimos que representan una busqueda, como son la ruta,
//                 el token y el boleano subdirectorios (si hay que`proseguir
//                 la busqueda en las subcarpetas)
//                 El objeto TBuscador crea una instancia por cada una de las rutas
//
constructor TBusqueda.Create(ARuta: string; ASubcarpetas: boolean);
begin
   inherited Create;
   FRuta := ARuta;
   FSubcarpetas := ASubcarpetas;
end;




{class TBuscador}

//
// TBuscador
//



//  Proc/Fun     : constructor Create
//
//  Valor retorno: vacío
//  Parametros   : AOwner: TComponent
//
//  Comentarios  : Constructor de la clase TBuscador. Es el objeto central,
//                 sobre el que recae la responsabilidad de ofrecer resultados
//                 Mantiene una lista para almacenar los hilos creados, otra
//                 lista para las rutas y una tercera para los resultados
//                 encontrados.
//                 Se hace necesario mantener un estado del componente: partimos
//                 siempre de un estado inactivo y se alcanza de nuevo al finalizar
//                 la busqueda, con cancelación o con exito. Si se ha finalizado
//                 mediante cancelación, el estado del compomente también lo indica.
//
constructor TBuscador.Create(AOwner: TComponent);
begin
   inherited;

   FHilos := TListaHilos.Create;
   FRutas := TStringList.Create;
   FResultado := TStringList.Create;

   FEstado := [ebInactivo];
end;


//  Proc/Fun     : destructor Destroy
//
//  Valor retorno: vacio
//  Parametros   : vacio
//
//  Comentarios  : Destructor de la clase Tbuscador.
//                 Se liberan aquellas clases creadas dinámicamente y la memoria
//                 asociada.
//
destructor TBuscador.Destroy;
var
   i: integer;
begin
   // importante cancelar todo antes de que desaparezcamos de este mundo
   if ebBuscando in FEstado then
      Cancel();

   FHilos.Free;
   FResultado.Free;

   // liberar los objetos TBusqueda que han quedado almacenados dentro de FRutas.
   for i:=FRutas.count-1 downto 0 do
      if FRutas.Objects[i] <> nil then
         FRutas.Objects[i].Free;

   FRutas.Free;

   inherited;
end;


//  Proc/Fun     : procedure AddRuta
//
//  Valor retorno: Integer
//  Parametros   : ruta: string; subcarpetas: boolean
//
//  Comentarios  : Procedimiento público para la inserción de una nueva ruta.
//                 Se facilita como parametros la ruta y el booleano subcarpetas.
//                 Hay que tener en cuenta que una ruta puede ser añadida de dos
//                 formas distintas: mediante ésta, y mediante la asignación de
//                 la propiedad Rutas (procedimiento de escritura SetRutas)
//                 Devuelve como retorno el indice de la inserción
//
function TBuscador.AddRuta(ruta: string; subcarpetas: boolean): Integer;
begin
   Result:= FRutas.AddObject(ruta, TBusqueda.Create(ruta, subcarpetas));
end;


//  Proc/Fun     : procedure Execute
//
//  Valor retorno: vacío
//  Parametros   : vacío
//
//  Comentarios  : Metodo de ejecución del buscador
//                 Condicionamos la ejecución a que existan rutas de búsqueda
//                 y que el buscador no se encuentre en estado activo
//
procedure TBuscador.Execute;
begin
   if FRutas.count = 0 then
      raise ESinRutas.Create('No hay rutas de búsqueda configuradas.');

   if ebBuscando in FEstado then
      raise EBuscando.Create('La búsqueda ya está activa.');

   FEstado := [ebPausado, ebBuscando];

   FResultado.BeginUpdate;
   try
      FResultado.Clear;
   finally
      FResultado.EndUpdate;
   end;

   CrearBusquedas;  // creación de las busquedas - lanzamiento del algoritmo

   Pausado := false;
end;


//  Proc/Fun     : procedure CrearBusquedas
//
//  Valor retorno: vacío
//  Parametros   : vacío
//
//  Comentarios  : Lanzamiento del algoritmos de busqueda y creación de un hilo
//                 de ejecución por ruta solicitada por el usuario
//                 Finalmente son asignados los eventos de actualización del
//                 interfaz y comunicación de resultados
//
procedure TBuscador.CrearBusquedas;
var
   i: integer;
   hilo: THiloBusqueda;
   busqueda: TBusqueda;
begin
   for i:=0 to FRutas.count - 1 do
   begin
      if FRutas.Strings[i] <> '' then
      begin
         busqueda := TBusqueda(FRutas.Objects[i]);
         if busqueda = nil then
            hilo := THiloBusqueda.Create(FRutas.Strings[i], true)
         else
            hilo := THiloBusqueda.Create(busqueda.Ruta, busqueda.Subcarpetas);

         hilo.FreeOnTerminate := true;

         hilo.OnEncontrado := OnHiloEncontrado;
         hilo.OnTerminate  := OnHiloTerminate;

         FHilos.Add(hilo);
      end;
   end;
end;


//  Proc/Fun     : procedure Cancel
//
//  Valor retorno: vacío
//  Parametros   : vacío
//
//  Comentarios  : Acción de cancelar la búsqueda.
//
procedure TBuscador.Cancel;
var
   it: TIteradorHilos;
   hilo: TThread;
begin
   // primero pauso todo
   Pausado := true;

   // se utiliza el iterador para acceder al primer elemto.
   it := FHilos.CreateIterator();
   Include(FEstado, ebCancelado);
   try
      // cancelar los hilos y esperar a que cada uno de ellos se haya cancelado
      while it.Next <> nil do
      begin
         hilo := it.Current;

         hilo.Terminate();
         hilo.Resume();
      end;

   finally
      FEstado := [ebInactivo, ebCancelado];
      FHilos.ReleaseIterator(it);
   end;

end;


//
// Llamadas a los eventos del componente
//


//  Proc/Fun     : procedure CallOnEncontrado
//
//  Valor retorno: vacío
//  Parametros   : hilo: THiloBusqueda; ind: integer
//
//  Comentarios  : Lanzamiento del evento FOnEncontrado
//                 Cada vez que es resulta positivamente una coincidencia es
//                 invocado este metodo que dispara el evento, comunicando a
//                 nuestra aplicacion usuaria la cadena encontrada y el indice
//
procedure TBuscador.CallOnEncontrado(hilo: THiloBusqueda; ind: integer);
begin
   //
   // Atento: se llama al evento si está asignado *Y* no se está destruyendo el componente.
   // Esto es debido a que, cuando el componente se está destruyendo, no quiero que se
   // lancen los eventos, ya que es muy posible que dentro de esos eventos se haga
   // referencia a objetos del Form que ya no existan.
   //
   if Assigned(FOnEncontrado) and (not (csDestroying in ComponentState)) then
      FOnEncontrado(hilo, FResultado[ind], ind);
end;


//  Proc/Fun     : procedure CallOnFinHilo
//
//  Valor retorno: vacío
//  Parametros   : hilo: THiloBusqueda
//
//  Comentarios  : Lanzamiento del evento OnFinHilo.
//                 Cada vez que ha finalizado la exploración de una ruta y antes
//                 de que se produzca la destrucción del thread, lanzamos el evento
//                 de comunicación, indicando el total de encuentros obtenidos por
//                 el hilo
//
procedure TBuscador.CallOnFinHilo(hilo: THiloBusqueda);
begin
   if Assigned(FOnFinHilo)  and (not (csDestroying in ComponentState)) then
      FOnFinHilo(hilo, hilo.TotalEncontrado);
end;


//  Proc/Fun     : procedure CallOnFinBusqueda
//
//  Valor retorno: vacío
//  Parametros   : vacío
//
//  Comentarios  : Lanzamiento del evento FinBusqueda
//                 El componente Buscador, necesita comunicar a nuestra aplicación
//                 usuaria que ha finalizado su ejecución y que el último de los
//                 threads esta siendo destruido.
//                 La aplicación hará uso de este evento para restaurar los controles
//                 bloqueados, si ha echo uso de enabled para ello.
//
procedure TBuscador.CallOnFinBusqueda;
begin
   if Assigned(FOnFinBusqueda)  and (not (csDestroying in ComponentState)) then
      FOnFinBusqueda(self);
end;



//
// Eventos del hilo
//


//  Proc/Fun     : procedure OnHiloEncontrado
//
//  Valor retorno: vacío
//  Parametros   : hilo: THiloBusqueda; ruta: string
//
//  Comentarios  : Evento de uso privado del componente.
//                 Su implementación es un enlace intermedio hacia el evento público
//
procedure TBuscador.OnHiloEncontrado(hilo: THiloBusqueda; ruta: string);
var
   ind: integer;
begin
   ind := FResultado.AddObject(ruta, hilo);
   CallOnEncontrado(hilo, ind);
end;


//  Proc/Fun     : procedure OnHiloTerminate
//
//  Valor retorno: vacío
//  Parametros   : Sender: TObject
//
//  Comentarios  :  Evento de uso privado del componente.
//                  Su implementación es un enlace intermedio hacia el evento público
//                  Es asignado al evento OnTerminate de la clase TThread, que es
//                  lanzado previo a su destrucción y destro del ambito de Synchronize()
//
procedure TBuscador.OnHiloTerminate(Sender: TObject);
var
   hilo: THiloBusqueda;
begin
   hilo := sender as THiloBusqueda;

   FHilos.Remove(hilo);

   // se notifica del fin de hilo
   CallOnFinHilo(hilo);

   //
   // se notifica de que ya no quedan hilos (fin de la busqueda)
   //
   if FHilos.count = 0 then
   begin
      Exclude(FEstado, ebBuscando);
      Include(FEstado, ebInactivo);
      CallOnFinBusqueda();
   end;
end;



//
// setters/getters
//


//  Proc/Fun     : function GetPausado
//
//  Valor retorno: Boolean
//  Parametros   : Vacío
//
//  Comentarios  : Método de lectura de la propiedad Pausado.
//
function TBuscador.GetPausado: boolean;
begin
   result := (ebPausado in FEstado);
end;


//  Proc/Fun     : procedure SetPausado
//
//  Valor retorno: Vacío
//  Parametros   : value: boolean
//
//  Comentarios  : Método de escritura de la propiedad Pausado
//                 Se puede resaltar el uso de una clase especializada en la
//                 gestión y manipulación de los hilos, que es la clase iteradora,
//                 TIterador.
//
procedure TBuscador.SetPausado(value: boolean);
var
   it: TIteradorHilos;
begin
   if GetPausado <> value then
   begin

      if value then
      begin
         if ebBuscando in FEstado then
            Include(FEstado, ebPausado)
         else
            exit;
      end
      else
         Exclude(FEstado, ebPausado);

      //
      // recorrer la lista de hilos haciendo el resume/suspend.
      // Este es el típico ejemplo del uso del patrón "Iterator"
      //
      it := FHilos.CreateIterator();
      try
         while it.Next <> nil do
            if value then
               it.Current.Suspend()
            else
               it.Current.Resume();

      finally
         FHilos.ReleaseIterator(it);
      end;
   end;
end;


//  Proc/Fun     : procedure SetRutas
//
//  Valor retorno: Vacío
//  Parametros   : value: TStrings
//
//  Comentarios  : Una de las ideas que se persigue es hacer uso de la clase
//                 TCollection para almacenar las rutas en tiempo de diseño,
//                 creando en un plazo futuro un editor especializado para la
//                 introducción de las rutas desde el ide y que están sean
//                 almacenadas mediante persistencia.
//
// Comentario interno: esto desaparecerá cuando utilizamos el TCollection
//
procedure TBuscador.SetRutas(value: TStrings);
begin
   FRutas.Assign(value);
end;


end.
