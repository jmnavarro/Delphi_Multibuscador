//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//
// Programa: MultiFind   -Ventana principal de la aplicación-
//
// Propósito:
//    Este pequeño programa realiza una búsqueda de archivos utilizando programación
//    multi-hilo.
//    El buscador estándar de Window permite también realizar búsquedas en varias rutas,
//    pero las realiza en serie, es decir: cuando termina de buscar en una carpeta comienza
//    con la siguiente.
//    Con este programa se puede buscar en varias carpetas de forma simultanea, mejorando así
//    el tiempo de búsqueda, especialmente en búsquedas sobre unidades de red de distintos
//    servidores (mejora los tiempos del buscador de Windows en un 140% para unidades locales
//    de disco duro y en un 300% para unidades en red.
//
//    La idea original y el desarrollo son de Salvador Jover (www.sjover.com) y JM (www.lawebdejm.com).
//    Realizado inicialmente para la revista Síntesis del Grupo Albor (www.grupoalbor.com)';
//
// Autor:          Salvador Jover (www.sjover.com) y JM (www.lawebdejm.com)
// Fecha:          01/07/2003
// Observaciones:  Unidad creada en Delphi 5
// Copyright:      Este código es de dominio público y se puede utilizar y/o mejorar siempre que
//                 SE HAGA REFERENCIA AL AUTOR ORIGINAL, ya sea a través de estos comentarios
//                 o de cualquier otro modo.
//
//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, ActnList, Menus, Archivo, ImgList,
  Buscador, IconosAsociados;

type
  TSortType = (stUndefined, stAscending, stDescending);

  TMainForm = class(TForm)
    s: TShape;
    Label1: TLabel;
    Bevel1: TBevel;
    b_anadir: TButton;
    b_eliminar: TButton;
    Label2: TLabel;
    Bevel2: TBevel;
    lv_resultado: TListView;
    b_modificar: TButton;
    b_buscar: TButton;
    ico: TAnimate;
    Label3: TLabel;
    Label4: TLabel;
    l_lwdjm: TLabel;
    lv_busquedas: TListView;
    pm_busqueda: TPopupMenu;
    Aadir1: TMenuItem;
    Eliminar1: TMenuItem;
    Modificar1: TMenuItem;
    acciones: TActionList;
    a_anadir: TAction;
    a_eliminar: TAction;
    a_modificar: TAction;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Shape1: TShape;
    l_encontrados: TLabel;
    l_tiempo: TLabel;
    l_hilos: TLabel;
    tiempo: TTimer;
    b_acerca: TButton;
    b_Cancelar: TButton;
    a_abrir: TAction;
    a_abrircarpeta: TAction;
    pm_resultado: TPopupMenu;
    Abrir1: TMenuItem;
    Abrircarpetacontenedora1: TMenuItem;
    N1: TMenuItem;
    Cambiarnombre1: TMenuItem;
    a_explorar: TAction;
    Explorarcarpetacontenedora1: TMenuItem;
    l_salva: TLabel;
    a_cambiarnombre: TAction;
    EliminarArch: TMenuItem;
    a_eliminararch: TAction;
    N2: TMenuItem;
    Propiedades1: TMenuItem;
    N3: TMenuItem;
    Copiar1: TMenuItem;
    a_copiararch: TAction;
    a_propiedades: TAction;
    procedure FormCreate(Sender: TObject);
    procedure a_anadirExecute(Sender: TObject);
    procedure a_eliminarExecute(Sender: TObject);
    procedure a_modificarExecute(Sender: TObject);
    procedure b_buscarClick(Sender: TObject);
    procedure lv_busquedasChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure lv_busquedasEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
    procedure tiempoTimer(Sender: TObject);
    procedure lv_resultadoColumnClick(Sender: TObject; Column: TListColumn);
    procedure lv_resultadoCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure l_AutoresClick(Sender: TObject);
    procedure b_acercaClick(Sender: TObject);
    procedure b_CancelarClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure a_abrirExecute(Sender: TObject);
    procedure a_carpetaExecute(Sender: TObject);
    procedure pm_resultadoPopup(Sender: TObject);
    procedure a_explorarExecute(Sender: TObject);
    procedure a_cambiarnombreExecute(Sender: TObject);
    procedure lv_resultadoEdited(Sender: TObject; Item: TListItem; var S: String);
    procedure a_eliminararchExecute(Sender: TObject);
    procedure a_copiararchExecute(Sender: TObject);
    procedure a_propiedadesExecute(Sender: TObject);
  private
    FBuscador: TBuscador;

    FIconos: TIconosAsociados;

    FColumnaOrden: TListColumn;
    FSortType: TSortType;

    procedure LoadAVI;

    procedure OnEncontrado(Sender: TThread; archivo: string; index: integer);
    procedure OnFinHilo(Sender: TThread; TotalEncontrado: integer);
    procedure OnFinBusqueda(Sender: TBuscador);

    function BuscarCarpetaBusqueda(ruta: string): integer;

    procedure IniciarBusqueda;
    procedure PausarBusqueda;
    procedure ReanudarBusqueda;

    function GetArchivoActual: IArchivo;
  public
    property ArchivoActual: IArchivo read GetArchivoActual;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

// Se incluye el recurso AVI situado en el archivo "find.res". Este archivo se ha
// creado compilando el recurso fuente de "find.rc", ejecutando el comando:
//    C:\>Delphi5\Bin\brc32.exe -fofind.res -v find.rc

{$R res\find.res}


uses AnadirRuta, HiloBusqueda, ShellAPI;


resourcestring

   SCarpetaExistente = 'La carpeta de búsqueda "%s" ya existe.'#10#13#10#13'Debe introducir una carpeta de búsqueda distinta a las existentes.';
   SCarpetaExistenteTitle = 'Añadir carpeta';

   SBusquedaCancelada = 'Proceso de búsqueda cancelado por el usuario.';
   SBusquedaCanceladaTitle = 'Búsqueda cancelada';

   SBusquedaFinalizada = 'Se han encontrado %d ocurrencias.';
   SBusquedaFinalizadaTitle = 'Búsqueda finalizada';

   SBuscadorEjecutando = 'El buscador está ejecutándose, por lo que si ' +
                         'cierras la ventana se cancelará la busqueda.'#13#10#13#10 +
                         '¿Estás seguro que quieres continuar?';

   SBuscador = 'Buscador';

   SBuscar   = 'Buscar';
   SPausar   = 'Pausar';
   SReanudar = 'Reanudar';

   SAcerca = 'Este pequeño programa realiza una búsqueda de archivos utilizando programación multi-hilo.'+#10#13+
             'El buscador estándar de Window permite también realizar búsquedas en varias rutas, pero las realiza en serie, es decir: cuando termina de buscar en una carpeta comienza con la siguiente.'+#10#13+
             'Con este programa se puede buscar en varias carpetas de forma simultanea, mejorando así el tiempo de búsqueda, especialmente en búsquedas sobre unidades de red de distintos servidores '+
             '(mejora los tiempos del buscador de Windows en un 140% para unidades locales de disco duro y en un 300% para unidades en red.)'+#10#13#10#13+
             'La idea original y el desarrollo son de Salvador Jover (www.sjover.com) y JM (www.lawebdejm.com).'#10#13'Realizado inicialmente para la revista Síntesis del Grupo Albor (www.grupoalbor.com)';

   SSi = 'Sí';
   SNo = 'No';


//
// Se incluye un módulo donde se definen funciones para compatibilidad.
//
{$I compatible.inc}


//  Proc/Fun     : procedure FormCreate
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Evento de creación del formulario principal. Crearemos el
//                 buscador. En este caso, lo creamos dinámicamente pero nos
//                 bastaría tenerlo instalado en el ide para hacer uso del mismo
//                 en tiempo de diseño
//
procedure TMainForm.FormCreate(Sender: TObject);
begin
	FBuscador := TBuscador.Create(self);
   FBuscador.OnEncontrado  := OnEncontrado;
   FBuscador.OnFinHilo     := OnFinHilo;
   FBuscador.OnFinBusqueda := OnFinBusqueda;

   // cargar la animación
   LoadAVI();

   // crear la lista de iconos (TImageList
   FIconos := TIconosAsociados.Create(self);
   lv_resultado.SmallImages := FIconos;

   // cuando se utilza la propiedad Anchors de los componentes, se produce un
   // parpadeo que se puede evitar con el doble buffer (a costa de más memoria).
   self.DoubleBuffered := true;
end;


//  Proc/Fun     : procedure a_anadirExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Evento del componente TAction (Acciones). Nos permite
//                 añadir una ruta nueva en el cuadro de rutas
//
procedure TMainForm.a_anadirExecute(Sender: TObject);
var
   item: TListItem;
   dlg: TAnadirRutaForm;
   str: string;
   encontrado: boolean;
begin
   dlg := TAnadirRutaForm.Create(nil);
   try
      dlg.Carpeta     := 'C:\';
      dlg.Mascara     := '*.*';
      dlg.Subcarpetas := true;
      dlg.Modo        := mvAnadir;

      if dlg.ShowModal = mrOK then
      begin
         str := IncludeTrailingBackSlash(dlg.Carpeta) + dlg.Mascara;

         encontrado := (BuscarCarpetaBusqueda(str) <> -1);

         if encontrado then
            MessageBox(handle, PChar(Format(SCarpetaExistente, [str])),
                       PChar(SCarpetaExistenteTitle), MB_ICONWARNING)
         else
         begin
            item := lv_busquedas.Items.Add;
            item.Caption := IntToStr(lv_busquedas.Items.Count);
            item.Subitems.Add(str);
            if dlg.Subcarpetas then
               item.SubItems.Add(SSi)
            else
               item.SubItems.Add(SNo);

            item.SubItems.Add('?');

            lv_busquedas.Selected := item;
            item.MakeVisible(false);

            a_eliminar.enabled  := lv_busquedas.items.count > 0;
            a_modificar.enabled := a_eliminar.enabled;
            b_buscar.enabled    := true;
         end;
      end;

   finally
      dlg.Free;
   end;
end;


//  Proc/Fun     : procedure a_eliminarExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Evento del componente TAction (Acciones). Nos permite
//                 eliminar una ruta del cuadro de rutas
//
procedure TMainForm.a_eliminarExecute(Sender: TObject);
var
   i: integer;
begin
   if lv_busquedas.Selected <> nil then
   begin
      lv_busquedas.Items.Delete(lv_busquedas.Selected.Index);

      for i := 0 to Pred(lv_busquedas.Items.Count) do
         lv_busquedas.Items[i].Caption := IntToStr(i+1);

      a_eliminar.enabled  := lv_busquedas.items.count > 0;
      a_modificar.enabled := a_eliminar.enabled;
      b_buscar.enabled    := lv_busquedas.items.count > 0;
   end;
end;


//  Proc/Fun     : procedure a_modificarExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Evento del componente TAction (Acciones). Nos permite
//                 modificar una ruta del cuadro de rutas
//
procedure TMainForm.a_modificarExecute(Sender: TObject);
var
   dlg: TAnadirRutaForm;
   str: string;
   ind: integer;
begin
   if (lv_busquedas.Selected = nil) or (ebBuscando in FBuscador.Estado) then
      exit;

   dlg := TAnadirRutaForm.Create(nil);
   try
      dlg.Carpeta     := IncludeTrailingBackSlash(ExtractFilePath(lv_busquedas.Selected.SubItems[0]));
      dlg.Mascara     := ExtractFileName(lv_busquedas.Selected.SubItems[0]);
      dlg.Subcarpetas := lv_busquedas.Selected.SubItems[1] = SSi;
      dlg.Modo        := mvModificar;

      if dlg.ShowModal = mrOK then
      begin
         str := IncludeTrailingBackSlash(dlg.Carpeta) + dlg.Mascara;
         ind := BuscarCarpetaBusqueda(str);

         if (ind <> -1) and (ind <> lv_busquedas.Selected.Index) then
            MessageBox(handle, PChar(Format(SCarpetaExistente, [str])),
                       PChar(SCarpetaExistenteTitle), MB_ICONWARNING)
         else
         begin
            lv_busquedas.Selected.SubItems[0] := str;

            if dlg.Subcarpetas then
               lv_busquedas.Selected.SubItems[1] := SSi
            else
               lv_busquedas.Selected.SubItems[1] := SNo
         end;
      end;

   finally
      dlg.Free;
   end;
end;


//  Proc/Fun     : procedure b_buscarClick
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Pulsación del botón buscar. Evento click. Ejecuta acción
//                 de busqueda del componente buscador. Comprueba estado.
//
procedure TMainForm.b_buscarClick(Sender: TObject);
begin
   if ebInactivo in FBuscador.Estado then
      IniciarBusqueda()
   else if (ebBuscando in FBuscador.Estado) and (not (ebPausado in FBuscador.Estado)) then
      PausarBusqueda()
   else if (ebBuscando in FBuscador.Estado) and (ebPausado in FBuscador.Estado) then
      ReanudarBusqueda();
end;


//  Proc/Fun     : procedure b_CancelarClick
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Pulsación del botón cancelar. Evento click. Ejecuta acción
//                 de cancelar búsqueda en el componente.
//
procedure TMainForm.b_CancelarClick(Sender: TObject);
begin
   fBuscador.Cancel;
   b_Cancelar.Enabled := false;
   tiempo.enabled := false;
end;


//  Proc/Fun     : procedure TMainForm.LoadAVI
//
//  Valor retorno: vacio
//
//  Comentarios  : Asigna al componente TAnimate el número de recurso de la animación,
//                 incluída como recurso dentro del propio ejecutable.
//
procedure TMainForm.LoadAVI;
const
   RES_ID = 1000;
begin
   ico.ResId := RES_ID;
   ico.Show;
end;


//  Proc/Fun     : procedure TMainForm.OnEncontrado
//
//  Valor retorno: vacio
//  Parametros   : Sender: TThread; archivo: string; index: integer
//
//  Comentarios  : Cada vez que se produce una coincidencia entre nuestro token
//                 y el archivo explorado, se lanza el evento OnEncontrado para
//                 que podamos actualizar nuestro interfaz gráfico
//
procedure TMainForm.OnEncontrado(Sender: TThread; archivo: string; index: integer);
var
   ind, i: integer;
   item: TListItem;
   aux: string;
begin
   ind  := 0;
   item := nil;
   for i:=0 to Pred(lv_busquedas.items.count) do
      if lv_busquedas.items[i].SubItems[0] = THiloBusqueda(Sender).Ruta then
         item := lv_busquedas.items[i];

   if item <> nil then
   begin
      item.SubItems[2] := IntToStr(StrToInt(item.SubItems[2]) + 1);
      ind := item.index;
   end;

   l_encontrados.tag := l_encontrados.tag + 1;
   l_encontrados.caption := IntToStr(l_encontrados.tag);

   item := lv_resultado.Items.Add();
   item.Caption := ExtractFileName(archivo);

   aux := ExcludeTrailingBackSlash(ExtractFilePath(archivo));
   if Length(aux) = 2 then // raíz
      aux := aux + '\';
   item.SubItems.Add(aux);

   item.SubItems.Add('#' + IntToStr(ind+1));

	//item.MakeVisible(false); // esto ralentiza demasiado

   // extraer y mostrar el icono asociado, utilizando una clase que gestiona la
   // repetición de iconos.
   item.ImageIndex := FIconos.AddIconoAsociado(archivo);

   application.ProcessMessages;
end;


//  Proc/Fun     : procedure OnFinHilo
//
//  Valor retorno: vacio
//  Parametros   : Sender: TThread; TotalEncontrado: integer
//
//  Comentarios  : Este evento se dispara una vez que ha acabado de explorar una
//                 ruta. En un futuro nos permitirá monitorizar una linea de modificaciones
//                 sobre la shell, creando un hilo de notificación por cambios producidos
//                 una vez finalizada la busqueda y hasta que sea iniciada otra o bien
//                 sea cerrada la aplicación
//                 Esta característica es incorporada actualmente en el buscador de
//                 Windows y no es compatible con W95 y W98, dado el uso que hace de
//                 funciones como ReadDirectoryChanges que no son soportados por estos.
//
procedure TMainForm.OnFinHilo(Sender: TThread; TotalEncontrado: integer);
var
   i: integer;
   item: TListItem;
begin
   item := nil;
   for i:=0 to lv_busquedas.items.count-1 do
      if lv_busquedas.items[i].SubItems[0] = THiloBusqueda(Sender).Ruta then
         item := lv_busquedas.items[i];

   if item <> nil then
      item.Checked := true;

   l_hilos.tag := l_hilos.tag - 1;
   l_hilos.caption := IntToStr(l_hilos.tag);
end;


//  Proc/Fun     : procedure OnFinBusqueda
//
//  Valor retorno: vacio
//  Parametros   : sender: TBuscador
//
//  Comentarios  : Se dispara el evento al finalizar con exito la busqueda de
//                 todas las rutas. Nos anuncia la necesidad de actualizar el
//                 interfaz grafico, liberando aquellos objetos que habían sido
//                 bloqueados: botones de acceso a las listas, menús popup.
//
procedure TMainForm.OnFinBusqueda(Sender: TBuscador);
begin
   lv_busquedas.color      := clWindow;
   lv_busquedas.CheckBoxes := false;
   lv_busquedas.Enabled    := true;

   ico.active     := false;
   tiempo.Enabled := false;

   b_buscar.Caption   := SBuscar;
   b_cancelar.Enabled := false;

   a_anadir.enabled    := true;
   a_eliminar.enabled  := (lv_busquedas.items.count > 0);
   a_modificar.enabled := a_eliminar.enabled;

   if (ebCancelado in FBuscador.Estado) then
      MessageBox(handle, PChar(SBusquedaCancelada), PChar(SBusquedaCanceladaTitle),
                 MB_ICONINFORMATION)
   else
      MessageBox(handle, PChar(Format(SBusquedaFinalizada, [lv_resultado.Items.Count])),
                 PChar(SBusquedaFinalizadaTitle), MB_ICONINFORMATION);
end;


//  Proc/Fun     : procedure lv_busquedasChange
//
//  Valor retorno: vacio
//  Parametros   : Sender: TObject; Item: TListItem; Change: TItemChange
//
//  Comentarios  : Evento del TListView lv_busquedas. Nos permite mantener siempre
//                 en un estado consistente a nuestros botones de modificación y supresión
//                 de rutas. Pero ligamos este estado a que el buscador esté inactivo.
//
procedure TMainForm.lv_busquedasChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  if ebInactivo in FBuscador.Estado then
  begin
      a_eliminar.enabled  := (lv_busquedas.items.count > 0);
      a_modificar.enabled := a_eliminar.enabled;
  end;
end;


//  Proc/Fun     : procedure lv_busquedasEditing
//
//  Valor retorno: vacio
//  Parametros   : Sender: TObject; Item: TListItem; var AllowEdit: Boolean
//
//  Comentarios  : Evento Editing del cuadro de resultados.
//                 Permitimos o impedimos la moodificación de items a que
//                 el buscador esté inactivo. Se desactiva el atajo de teclado
//                 para que en la edición se pueda pulsar la tecla suprimir.
//
procedure TMainForm.lv_busquedasEditing(Sender: TObject; Item: TListItem; var AllowEdit: Boolean);
begin
   AllowEdit := (ebInactivo in fBuscador.Estado) and (Sender = lv_resultado);
   if AllowEdit then
   begin
      b_buscar.Default := false;
      a_eliminarArch.ShortCut := 0;
   end;
end;


//  Proc/Fun     : procedure tiempoTimer
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  :  Evento del TTimer. Actualizamos el label que actualiza el
//                  tiempo de búsqueda.
//
procedure TMainForm.tiempoTimer(Sender: TObject);
begin
   l_tiempo.Caption := IntToStr((GetTickCount - LongWord(l_tiempo.tag)) div 1000);
end;


//  Proc/Fun     : procedure lv_resultadoColumnClick
//
//  Valor retorno: vacio
//  Parametros   : Sender: TObject; Column: TListColumn
//
//  Comentarios  : Evento al pulsar sobre una de las columnas. Se produce la
//                 ordenación de la lista de resultados (s/columna pulsada)
//
procedure TMainForm.lv_resultadoColumnClick(Sender: TObject; Column: TListColumn);
begin
   FColumnaOrden := Column;
   lv_resultado.AlphaSort;

   case FSortType of
      stUndefined, stDescending:
         FSortType := stAscending;
      stAscending:
         FSortType := stDescending;
   end;
end;


//  Proc/Fun     : procedure lv_resultadoCompare
//
//  Valor retorno: vacio
//  Parametros   : Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer
//
//  Comentarios  : Función de analisis de comparación. Necesaria para establecer
//                 el orden. Este evento se dispara cuando dos items necesitan
//                 ser comparados
//
procedure TMainForm.lv_resultadoCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  if FColumnaOrden = lv_resultado.Columns[0] then
    compare := AnsiCompareText(Item1.Caption, Item2.Caption)
  else if FColumnaOrden = lv_resultado.Columns[1] then
    compare := AnsiCompareText(Item1.SubItems[0], Item2.SubItems[0])
  else if FColumnaOrden = lv_resultado.Columns[2] then
    compare := AnsiCompareText(Item1.SubItems[1], Item2.SubItems[1]);

  if FSortType = stAscending then
    compare := compare * -1;
end;


//  Proc/Fun     : procedure l_AutoresClick
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Para visitar la página de Salvador Jover y JM.
//
//
procedure TMainForm.l_AutoresClick(Sender: TObject);
begin
   (Sender as TLabel).Font.color := clPurple;
   ShellExecute(handle, nil, PChar('http://'+ (Sender as TLabel).caption +'/'), nil, nil, SW_NORMAL);
end;


//  Proc/Fun     : function BuscarCarpetaBusqueda
//
//  Valor retorno: integer
//  Parametros   : ruta: string
//
//  Comentarios  :  Esta función se ha añadido para evitar que en el procedimiento
//                  añadir ruta (TAction), se pueda duplicar una ruta, que tiene
//                  poco sentido para el usuario. Si la ruta ya existe devuelve
//                  la posición de la existente en el cuadro y se comunica al
//                  usuario.
//
function TMainForm.BuscarCarpetaBusqueda(ruta: string): integer;
var
   i: integer;
begin
   result := -1;
   for i := Pred(lv_busquedas.Items.Count) downto 0 do
      if lv_busquedas.Items[i].SubItems[0] = ruta then
      begin
         result := i;
         exit;
      end;
end;


//  Proc/Fun     : procedure IniciarBusqueda
//
//  Valor retorno: vacio
//  Parametros   : vacio
//
//  Comentarios  : Este procedimiento nos va a permitir que el buscador reciba
//                 las rutas de busqueda, para lo que se recorre el cuadro de
//                 rutas. Finalizado el ajuste del interfaz y el bloqueo de los
//                 elementos no accesibles en el nuevo estado, iniciamos la
//                 ejecución del buscador.
//
procedure TMainForm.IniciarBusqueda;
var
   i: integer;
   subcarpeta: boolean;
begin
   FBuscador.Rutas.Clear;
   for i:=0 to Pred(lv_busquedas.Items.count) do
   begin
      subcarpeta := lv_busquedas.Items[i].SubItems[1] = SSi;
      FBuscador.AddRuta(lv_busquedas.Items[i].SubItems[0], subcarpeta);
      lv_busquedas.Items[i].SubItems[2] := '0';
      lv_busquedas.items[i].Checked := False;
   end;

   // etiquetas de estadísticas
   l_encontrados.caption := '0';
   l_encontrados.tag     := 0;

   l_tiempo.caption := '0';
   l_tiempo.tag     := GetTickCount();

   l_hilos.caption := IntToStr(FBuscador.Rutas.Count);
   l_hilos.tag     := FBuscador.Rutas.Count;

   lv_busquedas.color      := clBtnFace;
   lv_busquedas.CheckBoxes := true;
   lv_busquedas.enabled    := false;

   // es importante hacer el BeginUpdate para acelerar la operación de limpieza
   lv_resultado.Items.BeginUpdate();
   try
      lv_resultado.Items.Clear();
   finally
      lv_resultado.Items.EndUpdate();
   end;

   // configurar las acciones
   a_anadir.enabled    := false;
   a_eliminar.enabled  := false;
   a_modificar.enabled := false;


   b_buscar.Caption   := SPausar;
   b_Cancelar.Enabled := true;

   ico.Active     := true;
   tiempo.enabled := true;
   
   FBuscador.Execute();
end;


//  Proc/Fun     : procedure PausarBusqueda
//
//  Valor retorno: vacio
//  Parametros   : vacio
//
//  Comentarios  :  Pausa en la busqueda
//
//
procedure TMainForm.PausarBusqueda;
begin
   FBuscador.Pausado := true;
   tiempo.enabled := false;
   ico.active := false;
   b_buscar.caption := SReanudar;
end;


//  Proc/Fun     : procedure ReanudarBusqueda
//
//  Valor retorno: vacio
//  Parametros   : vacio
//
//  Comentarios  :  Reanuda la busqueda tras la pausa
//
//
procedure TMainForm.ReanudarBusqueda;
begin
   FBuscador.Pausado := false;
   tiempo.enabled := true;
   ico.active := true;
   b_buscar.caption := SPausar;
end;


//  Proc/Fun     : function GetArchivoActual
//
//  Valor retorno: IArchivo
//  Parametros   : vacio
//
//  Comentarios  : Creación de la instancia de TArchivo. Mediante esta instancia
//                 manipulamos las acciones sobre los resultados, encapsulando
//                 y favoreciendo el aislamiento y la concentración del código.
//                 Se recae sobre la clase TArchivo la responsabilidad de la manipulación
//                 de los resultados.
//
function TMainForm.GetArchivoActual: IArchivo;
begin
   ASSERT(lv_resultado.Selected <> nil);

   // se crea un objeto que se liberará automaticamente cuando se pierdan las referencias
   result := TArchivo.Create(IncludeTrailingBackSlash(lv_resultado.Selected.SubItems[0]) +
                             lv_resultado.Selected.Caption);
end;


//  Proc/Fun     : procedure FormCloseQuery
//
//  Valor retorno: vacio
//  Parametros   : Sender: TObject; var CanClose: Boolean
//
//  Comentarios  : Avisamos a nuestro usuario de que la busqueda no ha concluido.
//                 Este evento es accesorio. Se puede probar a desactivarlo para
//                 verificar que no se produce excepción en el cierre de la ventana
//                 mientras los hilos estan en ejecución.
//                 Se pueden ampliar datos: Serie sobre Hilos de Ejecución (Síntesis)
//                 de quien escribe estos comentarios (sjc).
//
procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
   i: Integer;
begin

   if (ebBuscando in FBuscador.Estado) and not (ebPausado in FBuscador.Estado) then
   begin
      PausarBusqueda();
      if MessageBox(handle, PChar(SBuscadorEjecutando), PChar(SBuscador),
                    MB_ICONQUESTION + MB_YESNO) = ID_NO then
      begin
         CanClose:= false;
         ReanudarBusqueda();
         Exit;
      end;

      lv_resultado.Items.BeginUpdate;

      for i := Pred(lv_resultado.Items.Count) downto 0 do
         lv_resultado.Items.Item[i].ImageIndex := -1;
      lv_resultado.SmallImages := nil;
   end;
end;


//  Proc/Fun     : procedure b_acercaClick
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  :  Cuadro de Autoria y propositos.
//
//
procedure TMainForm.b_acercaClick(Sender: TObject);
begin
   MessageBox(handle, PChar(SAcerca), 'Acerca de...', MB_ICONINFORMATION);
end;


//  Proc/Fun     : procedure pm_resultadoPopup
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Las opciones del popup menu se desactivan si no está
//                 seleccionado el componente que lo invoca. Necesitamos
//                 que Selected nunca sea nil
//
procedure TMainForm.pm_resultadoPopup(Sender: TObject);
begin
   a_abrir.enabled := (lv_resultado.Selected <> nil);
   a_abrircarpeta.enabled := (lv_resultado.Selected <> nil);
   a_explorar.enabled := (lv_resultado.Selected <> nil);
   a_cambiarnombre.enabled := (lv_resultado.Selected <> nil);
   a_eliminararch.enabled := (lv_resultado.Selected <> nil);
   a_copiararch.enabled := (lv_resultado.Selected <> nil);
   a_propiedades.enabled := (lv_resultado.Selected <> nil);
end;


//  Proc/Fun     : procedure a_abrirExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  :  Ejecución de un archivo
//
//
procedure TMainForm.a_abrirExecute(Sender: TObject);
begin
   ArchivoActual.Abrir();
end;


//  Proc/Fun     : procedure a_carpetaExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Acción de Abrir carpeta en una ventana nueva de la shell
//
procedure TMainForm.a_carpetaExecute(Sender: TObject);
begin
   ArchivoActual.AbrirCarpeta();
end;


//  Proc/Fun     : procedure a_explorarExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  :  Acción de invocar la ventana del explorador
//
procedure TMainForm.a_explorarExecute(Sender: TObject);
begin
   ArchivoActual.ExplorarCarpeta();
end;


//  Proc/Fun     : procedure a_cambiarnombreExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Cuando deseamos cambiar el nombre a un archivo, esto puede
//                 hacerse, bien clickeando sobre el caption, bien pulsando sobre
//                 la opción del menú. Al hacer esto, iniciamos la edición del mismo
//                 y la acción de modificación propiamente se llevará a cabo
//                 en el momento en que se validen los cambios
//
procedure TMainForm.a_cambiarnombreExecute(Sender: TObject);
begin
   ASSERT(lv_resultado.Selected <> nil);
   lv_Resultado.Selected.EditCaption;
end;


//  Proc/Fun     : procedure lv_resultadoEdited
//
//  Valor retorno: vacio
//  Parametros   : Sender: TObject; Item: TListItem; var S: String
//
//  Comentarios  : Modificación del nombre de un archivo. Este evento se dispara
//                 al finalizar la edición
//
procedure TMainForm.lv_resultadoEdited(Sender: TObject; Item: TListItem; var S: String);
var
   archivo: IArchivo;
begin
   archivo := ArchivoActual;
   try
      TArchivo(archivo).Nombre := s;

      b_buscar.Default := true;
      a_eliminarArch.ShortCut := 46; // tecla supr.

   except on Exception do
      s := lv_resultado.Selected.Caption;
   end;
end;


//  Proc/Fun     : procedure a_eliminararchExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Acción de eliminar un archivo
//
procedure TMainForm.a_eliminararchExecute(Sender: TObject);
begin
   if ArchivoActual.Eliminar() = 0 then
      lv_resultado.Selected.Delete
end;


//  Proc/Fun     : procedure a_copiararchExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Acción de copiar un archivo al portapapeles.
//
procedure TMainForm.a_copiararchExecute(Sender: TObject);
begin
   ArchivoActual.CopiarAlPortapapeles();
end;


//  Proc/Fun     : procedure a_propiedadesExecute
//
//  Valor retorno: vacio
//  Parametros   : sender: TObject
//
//  Comentarios  : Acción de lanzar el cuadro de propiedades del archivo
//
procedure TMainForm.a_propiedadesExecute(Sender: TObject);
begin
   ArchivoActual.MostrarPropiedades();
end;

end.
