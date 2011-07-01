//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//
// Unidad: HiloBusqueda.pas
//
// Propósito:
//    Implementa un descendiente de TThread que realiza una búsqueda de archivos dentro de una
//    carpeta y sus correspondientes subcarpetas.
//    Esta clase puede utilizarse directamente, como cualquier otro TThread, pero está diseñada
//    para ser usada desde el componentes TBuscador, definido en Buscador.pas
//
// Autor:          Salvador Jover (www.sjover.com) y JM (www.lawebdejm.com)
// Fecha:          01/07/2003
// Observaciones:  Unidad creada en Delphi 5
// Copyright:      Este código es de dominio público y se puede utilizar y/o mejorar siempre que
//                 SE HAGA REFERENCIA AL AUTOR ORIGINAL, ya sea a través de estos comentarios
//                 o de cualquier otro modo.
//
//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
unit HiloBusqueda;

interface

uses classes, windows;


type
   THiloBusqueda = class; // forward

   TOnEncontrado = procedure(sender: THiloBusqueda; ruta: string)   of object;
   TOnEnd        = procedure(sender: THiloBusqueda; total: integer) of object;


   THiloBusqueda = class(TThread)
   private
      FRuta:        string;    // ruta a buscar
      FSubcarpetas: boolean;

      FRutaEncontrado: string; // aux para pasar a método sincronizado

      FOnEncontrado: TOnEncontrado;
      FOnEnd:        TOnEnd;

      function BuscarArchivos(const carpeta: string): integer;
      function BuscarSubcarpetas(const carpeta: string): integer;

      function GetTotalEncontrado: integer;

   protected
      procedure DoCallOnEncontrado;
      procedure CallOnEncontrado(const ruta: string);

      procedure CallOnEnd;

      function BuscarEnCarpeta(carpeta: string): integer; virtual;

      procedure Execute; override;   // Método execute de la clase TThread

   public
      constructor Create(const ARuta: string; const ASubcarpetas: boolean); reintroduce;

      property Ruta:        string  read FRuta;
      property Subcarpetas: boolean read FSubcarpetas;
      property TotalEncontrado: integer read GetTotalEncontrado;

      property OnEncontrado: TOnEncontrado read FOnEncontrado write FOnEncontrado;
      property OnEnd:        TOnEnd        read FOnEnd        write FOnEnd;
   end;


   TIteradorHilos = class;

   //
   // Clase auxiliar que define una lista de hilos
   //
   TListaHilos = class(TList)
   private
      function GetHilo(i: integer): THiloBusqueda;

   public
      function CreateIterator: TIteradorHilos;
      procedure ReleaseIterator(var it: TIteradorHilos);

      property Items[i: integer]: THilobusqueda read GetHilo; default;
   end;


   //
   // Un iterador para recorrer la lista de hilos
   //
   TIteradorHilos = class(TObject)
   private
      FListaHilos: TListaHilos;

      FIndex:   integer;

      function GetCurrent:  THiloBusqueda;
      function GetFirst:    THiloBusqueda;
      function GetLast:     THiloBusqueda;
      function GetNext:     THiloBusqueda;
      function GetPrevious: THiloBusqueda;

   public
      constructor Create(lista: TListaHilos);

      property Current:  THiloBusqueda read GetCurrent;
      property First:    THiloBusqueda read GetFirst;
      property Last:     THiloBusqueda read GetLast;
      property Next:     THiloBusqueda read GetNext;
      property Previous: THiloBusqueda read GetPrevious;
   end;


implementation


uses SysUtils;


//
// Se incluye un módulo donde se definen funciones para compatibilidad.
//
{$I ..\compatible.inc}



//
// TIteratorHilos
//


//  Proc/Fun     : constructor Create
//
//  Valor retorno: vacío
//  Parametros   : lista: TListaHilos
//
//  Comentarios  : Contructor de la clase TIteradorHilos.
//                 Recae sobre esta clase la responsabilidad de recorrer la
//                 lista de hilos, y entregar al buscador una referencia a los
//                 mismos. Para esto dispone de los métodos apropiados para
//                 avanzar secuencialmente, almacenando la posición actual en la
//                 variable FIndex.
//                 TIterador actua a traves de la clase TListaHilos
//
constructor TIteradorHilos.Create(lista: TListaHilos);
begin
   inherited Create;

   FListaHilos := lista;
   FIndex      := -1;
end;


//  Proc/Fun     : function GetCurrent
//
//  Valor retorno: THiloBusqueda
//  Parametros   : vacío
//
//  Comentarios  : Obtener una referencia la hilo actual, indicado por el indice.
//                 Si se ha creado en ese momento la lista devuelve la posición
//                 neutra (-1) 'No hay selección'
//
function TIteradorHilos.GetCurrent: THiloBusqueda;
begin
   if FIndex = -1 then
      result := nil
   else
      result := FListaHilos[FIndex];
end;


//  Proc/Fun     : function GetFirst
//
//  Valor retorno: THiloBusqueda
//  Parametros   : vacio
//
//  Comentarios  : Obtener una referencia al primer hilo de la lista.
//
function TIteradorHilos.GetFirst: THiloBusqueda;
begin
   FIndex := 0;
   result := GetCurrent;
end;


//  Proc/Fun     : function GetLast
//
//  Valor retorno: THiloBusqueda
//  Parametros   : vacío
//
//  Comentarios  : Obtener una referencia al último hilo de la lista
//
function TIteradorHilos.GetLast: THiloBusqueda;
begin
   FIndex := FListaHilos.count - 1;
   result := GetCurrent;
end;


//  Proc/Fun     : function GetNext
//
//  Valor retorno: THiloBusqueda
//  Parametros   : vacío
//
//  Comentarios  : Obtener una referencia al siguiente hilo de la lista. Se
//                 incrementará FIndex
//
function TIteradorHilos.GetNext: THiloBusqueda;
begin
   Inc(FIndex);
   if (FIndex >= FListaHilos.count) then
      FIndex   := -1;

   result := GetCurrent;
end;


//  Proc/Fun     : function GetPrevious
//
//  Valor retorno: THiloBusqueda
//  Parametros   : vacío
//
//  Comentarios  : Obtener una referencia al anterior hilo de la lista. Se
//                 decrementa FIndex.
//
function TIteradorHilos.GetPrevious: THiloBusqueda;
begin
   Dec(FIndex);
   result := GetCurrent;
end;



//
// TListaHilos
//


//  Proc/Fun     : function GetHilo
//
//  Valor retorno: THiloBusqueda
//  Parametros   : i: integer
//
//  Comentarios  : Metodo para la obtención de la referencia al hilo. Es la
//                 propiedad de lectura del item de la lista y cuando se produce
//                 una asignación es invocado.
//
function TListaHilos.GetHilo(i: integer): THiloBusqueda;
begin
   result := THiloBusqueda(inherited items[i]);
end;


//  Proc/Fun     : function CreateIterator
//
//  Valor retorno: TIteradorHilos
//  Parametros   : vacío
//
//  Comentarios  :  Método de creación del iterador. Obtenemos una referencia
//                  al mismo que nos permitirá finalmente destruirlo, cuando ya
//                  no nos es necesario.
//
function TListaHilos.CreateIterator: TIteradorHilos;
begin
   result := TIteradorHilos.Create(self);
end;


//  Proc/Fun     : procedure ReleaseIterator
//
//  Valor retorno: vacío
//  Parametros   : var it: TIteradorHilos
//
//  Comentarios  : Método para la destrucción del iterador. TBuscador hará la
//                 invocación necesaria con la referencia obtenida anteriormente
//                 en la función creadora
//
procedure TListaHilos.ReleaseIterator(var it: TIteradorHilos);
begin
   it.Free;
   it := nil;
end;




//
// THiloBusqueda
//


//  Proc/Fun     : constructor Create
//
//  Valor retorno: vacío
//  Parametros   : const ARuta: string; const ASubcarpetas: boolean
//
//  Comentarios  : Constructor del thread.
//
constructor THiloBusqueda.Create(const ARuta: string; const ASubcarpetas: boolean);
begin
   inherited Create(true);

   FRuta := ARuta;
   FSubcarpetas := ASubcarpetas;
end;


//  Proc/Fun     : procedure Execute
//
//  Valor retorno: vacío
//  Parametros   : vacío
//
//  Comentarios  : Método que sobrescribe Execute en el descendiente.
//                 Lanzamos el hilo de ejecución y la exploración de carpetas
//
procedure THiloBusqueda.Execute;
begin
   //
   // Iniciamos el árbol de búsquedas
   //
   ReturnValue := BuscarEnCarpeta(FRuta);
   //Esta rutina no da problemas en delphi 5 pero en delphi 6 debe comentarse ya que
   //produce una excepción. En principio no resulta necesaria ya que está asignado el
   //evento onTerminate
   //  Synchronize(CallOnEnd);
end;

//******************
//  Ver nota aclaratoria final sobre el algoritmo recursivo de busqueda
//  empleado.
//******************

//  Proc/Fun     : function BuscarEnCarpeta
//
//  Valor retorno: Integer
//  Parametros   : carpeta: string
//
//  Comentarios  : Primer paso del algoritmo recursivo de busqueda
//                 Ver explicación adicional mas abajo.
//
function THiloBusqueda.BuscarEnCarpeta(carpeta: string): integer;
var
   ret: integer;
begin
   result := 0;

   //
   // primera vuelta para buscar los archivos en esta carpeta
   //
   ret := BuscarArchivos(PChar(carpeta));
   if ret = -1 then
   begin
      result := ret;
      exit;
   end
   else
      Inc(result, ret);

   //
   // segunda vuelta para buscar las subcarpetas de esta carpeta
   //
   if FSubcarpetas and (not Terminated) then
   begin
      ret := BuscarSubcarpetas(carpeta);
      if ret = -1 then
      begin
         result := ret;
         exit;
      end
      else
         Inc(result, ret);
   end;
end;


//  Proc/Fun     : function BuscarArchivos
//
//  Valor retorno: Integer
//  Parametros   : const carpeta: string
//
//  Comentarios  : Resuelve las coincidencias sobre la carpeta actual y lanza
//                 los enventos que resuelven los encuentros (coincidencia token
//                 y fichero explorado)
//
function THiloBusqueda.BuscarArchivos(const carpeta: string): integer;
var
   FindData:     WIN32_FIND_DATA;
   SearchHandle: THandle;
begin
   result := 0;

   SearchHandle := FindFirstFile(PChar(carpeta), FindData);
   if SearchHandle <> INVALID_HANDLE_VALUE then
   begin
      // Se itera en la carpeta actual
      repeat

         // si no es carpeta, es que lo ha encontrado
         if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0) then
         begin
            // encontrado
            FRutaEncontrado := ExtractFilePath(carpeta) + FindData.cFileName;
            Synchronize(DoCallOnEncontrado);

            Inc(result);
         end;

      until not FindNextFile(SearchHandle, FindData) or Terminated;

      // error en algún paso de la búsqueda
      if GetLastError <> ERROR_NO_MORE_FILES then
      begin
         result := -1;
      end;

      Windows.FindClose(SearchHandle);

   end
   else
      if GetLastError() = ERROR_FILE_NOT_FOUND then
         result := 0
      else
         result := -1;
end;


//  Proc/Fun     : function BuscarSubcarpetas
//
//  Valor retorno: Integer
//  Parametros   : const carpeta: string
//
//  Comentarios  : Segundo paso del algoritmo de busqueda. Busqueda de subcarpetas
//                 e invocación del procedimiento inicial BuscarEnCarpeta, generando
//                 la recursividad y garantizando la exploración de todo el arbor de
//                 directorios bajo la ruta indicada.
//
function THiloBusqueda.BuscarSubcarpetas(const carpeta: string): integer;
var
   FindData:     WIN32_FIND_DATA;
   SearchHandle: THandle;
   ret:          integer;
   mascara:      string;
   dir:          string;
begin
   result := 0;

   mascara := '\' + ExtractFileName(carpeta);
   dir     := ExtractFilePath(carpeta);
   dir     := IncludeTrailingBackSlash(dir) + '*.*';

   SearchHandle := FindFirstFile(PChar(dir), FindData);
   if SearchHandle <> INVALID_HANDLE_VALUE then
   begin
      // Se itera en la carpeta actual
      repeat

         // si es carpeta, hay que llamar recursivamente
         if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and
            (FindData.cFileName[0] <> '.')  then
         begin
            dir := ExtractFilePath(carpeta);
            dir := IncludeTrailingBackSlash(dir) + FindData.cFileName + mascara;

            ret := BuscarEnCarpeta(dir);
            if ret = -1 then
               result := -1
            else
               Inc(result, ret);
         end;

      until (not FindNextFile(SearchHandle, FindData)) or Terminated or (result = -1);

      // error en algún paso de la búsqueda
      if GetLastError <> ERROR_NO_MORE_FILES then
      begin
         result := -1;
      end;

      Windows.FindClose(SearchHandle);

   end
   else
      if GetLastError() = ERROR_FILE_NOT_FOUND then
         result := 0
      else
         result := -1;
end;


//  Proc/Fun     : procedure DoCallOnEncontrado
//
//  Valor retorno: vacío
//  Parametros   : vacío
//
//  Comentarios  :  Este método es invocado cada vez que es encontrada una coincidencia
//                  token - archivo, desencadenando en su invocación el evento OnEncontrado
//                  del que se sirve el componente buscador para su comunicacion. Esto es,
//                  nos valemos del metodo en una comunicación desde el hilo hacia el
//                  buscador, para que éste, tras hacer lo que crea conveniente, genere la
//                  comunicación a la aplicación usuaria
//
procedure THiloBusqueda.DoCallOnEncontrado;
begin
   CallOnEncontrado(FRutaEncontrado);
end;


//  Proc/Fun     : procedure CallOnEncontrado
//
//  Valor retorno: vacío
//  Parametros   : const ruta: string
//
//  Comentarios  : Evento de comunicación entre THiloBusqueda y nuestro buscador
//
procedure THiloBusqueda.CallOnEncontrado(const ruta: string);
begin
   if Assigned(FOnEncontrado) and not Terminated then
      FOnEncontrado(self, ruta);
end;


//  Proc/Fun     : procedure CallOnEnd
//
//  Valor retorno: vacío
//  Parametros   : vacío
//
//  Comentarios  :  Se persiguen los mismo objetivos que en nuestro método y
//                  evento anterior
//                  Se establece una comunicación THiloBusqueda -> Buscador para
//                  que este la pueda establecer hacia la aplicación usuaria
//
procedure THiloBusqueda.CallOnEnd;
begin
   if Assigned(FOnEnd) and not Terminated then
      FOnEnd(self, ReturnValue);
end;


//  Proc/Fun     : function GetTotalEncontrado
//
//  Valor retorno: Integer
//  Parametros   : Vacio
//
//  Comentarios  : Procedimiento de lectura del total de encontrados
//
function THiloBusqueda.GetTotalEncontrado: integer;
begin
   result := ReturnValue;
end;


{
//*****************
     NOTA ACLARATORIA:
        Esta nota es un pequeño estracto del artículo "TThread VI: Un buscador
        de Archivos (y II)" de quien escribe estas lineas y publicado en Síntesis
        en su número 16, y que explican brevemente el algoritmo diseñado por
        Jose Manuel Navarro.
//*****************
...
Vamos a suponer que deseamos iniciar una búsqueda cualquiera. En ocasiones
resultaría interesante crear tres o cuatro carpetas y un par de archivos en
el interior de ellas para simular ésta, y hacer un seguimiento desde Delphi,
paso por paso, en la exploración de este pequeño árbol. Yo lo he hecho así.
Puse un punto de parada justo en la linea que invoca Execute, y voy avanzando
paso a paso mediante la pulsación de F7, siguiendo en un la ventana de código
el valor de algunas de las variables. Supongamos que lo hacemos así:

procedure TJMBuscador.Execute;
begin
   fCountRes:= 0;
   if FRutas.count = 0 then
   	raise ESinRutas.Create('No hay rutas de búsqueda configuradas.');

   if FEstado in [ebPausado, ebBuscando] then
   	raise EBuscando.Create('La búsqueda ya está activa.');

   FEstado := ebPausado;
   FResultado.Clear;

   CrearBusquedas;

   Pausado := false;
end;

fCountRes representa al total de coincidencias encontradas por el buscador. Tras
inicializar este valor, y comprobar que existen rutas asignadas y que el componente
no se haya ya en estado de búsqueda o pausado, inicializa también la lista de
resultados y procede a crear cada uno de los hilos necesarios en CrearBusquedas.
Hecho esto, puede activar la ejecución del buscador. Un detalle que puede resultar
de interés para los compañeros que se inician, es observar como la misma propiedad,
nos puede ayudar  a desencadenar acciones a través de su escritura.

   FEstado := ebPausado;
   ...
   Pausado := false;

Juega Jose Manuel modificando directamente el valor de la variable fEstado,
que almacena el estado real del buscador, mientras que en un momento posterior,
lineas mas abajo, lo hace invocando a la propiedad Pausado, que no solo incidirá
sobre la misma variable, sino que, como efecto colateral y tras varias rutinas
de código, invocara finalmente al método Resume de cada uno de los hilos.
Nos podemos adelantar al momento en que se inicia la ejecución de uno de los
hilos creados en CrearBusquedas, y lanzados tras la asignación de Pausado a false.
El método Execute del hilo consta básicamente de una sola linea de código:

   ReturnValue := BuscarEnCarpeta(FRuta);

Esto nos lleva a comentar el primer punto clave del desarrollo del algoritmo.
La invocación de BuscarEnCarpeta( ) para inicializar la búsqueda en un nuevo
directorio. En este punto se inicia una nueva búsqueda, y como ya os debéis
imaginar, será esta misma rutina la que llamada posteriormente y desde otro
tramo de código genere la recursividad.

function TJMHiloBusqueda.BuscarEnCarpeta(carpeta: string): integer;
var
	ret: integer;
begin
	result := 0;

   //
   // primera vuelta para buscar los archivos en esta carpeta
   //
   ret := BuscarArchivos(PChar(carpeta));
   if ret = -1 then
   begin
   	result := ret;
     exit;
   end
   else
   	Inc(result, ret);

   //
   // segunda vuelta para buscar las subcarpetas de esta carpeta
   //
   if FSubcarpetas and (not Terminated) then
   begin
	   ret := BuscarSubcarpetas(carpeta);
      if ret = -1 then
      begin
      	result := ret;
        exit;
      end
      else
      	Inc(result, ret);
   end;
end;

Podemos subdividir la implementación de este procedimiento en dos fases
diferenciadas, de la misma forma que ya hemos hecho anteriormente: La fase de
búsqueda de coincidencias en la carpeta actual y una segunda fase, que Jose Manuel
denomina “segunda vuelta...” en esos comentarios de código y cuyo punto central
es la invocación de BuscarSubcarpetas. Lógicamente, solo se entrará en esta fase
si fSubcarpetas tiene valor verdadero, si queremos explorar las subcarpetas y si
el hilo no ha sido finalizado prematuramente (not Terminate).
Veamos que pasa en el interior del método BuscarSubcarpeta. Prescindimos de
aquellos trozos de código que resultan mas accesorios. Remarco en otro color la
llamada a BuscarEnCarpeta:

function TJMHiloBusqueda.BuscarSubcarpetas(const carpeta: string): integer;
var
   FindData:     WIN32_FIND_DATA;
   SearchHandle: THandle;
   ret: 			  integer;
   mascara:      string;
   dir:          string;
begin
   result := 0;

   mascara := '\' + ExtractFileName(carpeta);
   dir     := ExtractFilePath(carpeta);
   dir     := IncludeTrailingBackSlash(dir) + '*.*';

   SearchHandle := FindFirstFile(PChar(dir), FindData);
   if SearchHandle <> INVALID_HANDLE_VALUE then
   begin
      // Se itera en la carpeta actual
      repeat

         // si es carpeta, hay que llamar recursivamente
         if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0) and
            (FindData.cFileName[0] <> '.')  then
         begin
			   dir := ExtractFilePath(carpeta);
            dir := IncludeTrailingBackSlash(dir) + FindData.cFileName + mascara;

            ret := BuscarEnCarpeta(dir);
            if ret = -1 then
               result := -1
            else
               Inc(result, ret);
         end;

      until (not FindNextFile(SearchHandle, FindData)) or Terminated or (result = -1);

   ...
   ...

end;

Nos quedamos con los dos puntos claves de la implementación. El primero es la
obtención de la nueva ruta y que se representa en el parámetro dir, remarcado
en color naranja. El segundo punto clave es la llamada a BuscarEnCarpeta una vez
que se ha modificado anteriormente la variable dir con los valores correctos.
El bucle repeat ... until, que encierra este código, garantiza que la exploración
se va hacer para cada uno de los directorios que componen la carpeta actual.
Si este ciclo, tal y como lo hemos contado, lo trasladamos al interior de cada
uno de los directorios encontrados, garantizamos que la búsqueda se va a mantener
mientras quede alguna carpeta por explorar, recorriendo en profundidad todo el
árbol de directorios
...
}

end.
