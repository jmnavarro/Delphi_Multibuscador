//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//
// Programa: MultiFind
//
// Propósito Modulo Archivo:
//    El proposito de este modulo de Archivo, es el de encapsular en una clase las
//    acciones de manipulación de la shell de windows sobre el archivo seleccionado.
//    Esto nos permite una mayor claridad del código fuente y responde a los esquemas
//    habituales de encapsulamiento de estructuras y código.
//    El diseño se hace basado en la interfaz (IArchivo) que representa a todos aquellos
//    objetos que tienen la capacidad de manipular archivos.
//
//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
unit Archivo;

interface

type
   //
   // Se define el interfaz IArchivo que representa todas aquellas acciones que se
   // podrán realizar con el archivo
   //
   IArchivo = interface(IUnknown)
      function Eliminar:     integer;
      function Abrir:        integer;
      function AbrirCarpeta: integer;
      function ExplorarCarpeta: integer;
      function CopiarAlPortapapeles: integer;
      function MostrarPropiedades: integer;
   end;

   //
   // Se define una clase que haga una implementación concreta de IArchivo.
   // Además, esta clase desciende de TInterfacedObject, por lo que no será necesario
   // liberar los objetos creados, ya que se liberan solos.
   //
   TArchivo = class(TInterfacedObject, IArchivo)
   private
      FRuta:   string;
      FNombre: string;

      procedure SetNombre(const value: string);
      function GetNombreCompleto: string;

      property NombreCompleto: string read GetNombreCompleto;

   public
      constructor Create(filename: string);

      function Eliminar:     integer;
      function Abrir:        integer;
      function AbrirCarpeta: integer;
      function ExplorarCarpeta: integer;
      function CopiarAlPortapapeles: integer;
      function MostrarPropiedades: integer;

      property Nombre: string read FNombre write SetNombre;
   end;


implementation

uses Windows, ShellAPI, Forms, SysUtils;


//
// Se incluye un módulo donde se definen funciones para compatibilidad.
//
{$I compatible.inc}


//  Proc/Fun     : constructor Create
//
//  Valor retorno: vacio
//  Parametros   : filename: string
//
//  Comentarios  : Constructor de la clase
//
constructor TArchivo.Create(filename: string);
begin
   inherited Create;

   FRuta   := IncludeTrailingBackSlash(ExtractFilePath(filename));
   FNombre := ExtractFileName(filename);
end;


//  Proc/Fun     : procedure SetNombre
//
//  Valor retorno: vacio
//  Parametros   : const value: string
//
//  Comentarios  : Procedimiento de edición del nombre del archivo
//                 Acción cambiar nombre
//
procedure TArchivo.SetNombre(const value: string);
var
   SHFileOp: TSHFileOpStruct;
   ret: integer;
begin
   if FNombre <> value then
   begin
      shFileOp.Wnd := application.MainForm.Handle;    //manejador de la ventana sobre la que se realiza la operacion
      shFileOp.wFunc := FO_RENAME; //tipo de operacion

      // ojo: no olvidar #0 ya que si no genera error puesto que gracias al caracter
      //nulo "imagino" que se distingue origen-destino
      shFileOp.pFrom := PChar(NombreCompleto + #0); //ruta nombre a cambiar; ojo: si no existe ruta supone GetCurrentDir()
      shFileOp.pTo   := PChar(FRuta + value);   //ruta + nuevo nombre  ojo: si no existe ruta supone GetCurrentDir()

      //opciones de operacion
      shFileOp.fFlags:= FOF_RENAMEONCOLLISION or FOF_NOCONFIRMMKDIR;

      ret := SHFileOperation(shFileOp);
      if ret <> 0 then
         raise Exception.CreateFmt('Error renombrando archivo "%s"', [NombreCompleto]);
   end;
end;


//  Proc/Fun     : function GetNombreCompleto
//
//  Valor retorno: string
//  Parametros   : vacio
//
//  Comentarios  : Propiedad Nombre Completo. Función de lectura.
//
function TArchivo.GetNombreCompleto: string;
begin
   result := FRuta + FNombre;
end;


//  Proc/Fun     : function Eliminar
//
//  Valor retorno: Integer
//  Parametros   : Vacio
//
//  Comentarios  : Acción de eliminar un archivo.
//                 No eliminamos de forma directa. Enviamos a la papelera y dejamos
//                 que se le comunique al usuario la intención del borrado.
//                 Si es cancelada la acción lo comunica devolviendo -1.
//
function TArchivo.Eliminar: integer;
var
   SHFileOp: TSHFileOpStruct;
begin
   shFileOp.Wnd:= application.MainForm.Handle;    //manejador de la ventana sobre la que se realiza la operacion
   shFileOp.wFunc:= FO_DELETE; //tipo de operacion
   shFileOp.pFrom:= PChar(NombreCompleto+#0);
   shFileOp.pTo:= #0;
   //opciones de operacion
   shFileOp.fFlags:= FOF_ALLOWUNDO;
   Result:= SHFileOperation(shFileOp);
   //si la operación ha sido cancelada por el usuario
   if shFileOp.fAnyOperationsAborted then
      result:= -1;
end;


//  Proc/Fun     : function Abrir
//
//  Valor retorno: Integer
//  Parametros   : Vacio
//
//  Comentarios  : Ejecutar el archivo seleccionado. Si tiene exito devuelve 0. En
//                 caso contrario devuelve el error
//
function TArchivo.Abrir: integer;
var
   ret: HINST;
begin
   ret := ShellExecute(application.MainForm.handle, nil, PChar(NombreCompleto), nil, nil, SW_NORMAL);
   if ret >= HINSTANCE_ERROR then
      result := -1
   else
      result := 0;
end;


//  Proc/Fun     : function AbrirCarpeta
//
//  Valor retorno: Integer
//  Parametros   : Vacio
//
//  Comentarios  : Abrir en una ventana distinta de la shell, la carpeta que contiene
//                 el archivo seleccionado. Si tiene exito devuelve 0 en caso contrario
//                 el error
//
function TArchivo.AbrirCarpeta: integer;
var
   ret: HINST;
begin
   ret := ShellExecute(application.MainForm.handle, nil, PChar(FRuta), nil, nil, SW_NORMAL);
   if ret >= HINSTANCE_ERROR then
      result := -1
   else
      result := 0;
end;


//  Proc/Fun     : function ExplorarCarpeta
//
//  Valor retorno: Integer
//  Parametros   : Vacio
//
//  Comentarios  : Abrir en una ventana del explorador de la shell, la carpeta que contiene
//                 el archivo seleccionado. Si tiene exito devuelve 0 en caso contrario
//                 el error
//
function TArchivo.ExplorarCarpeta: integer;
var
   ret: HINST;
   cmd: string;
begin
   cmd := '/n, /e, "' + ExcludeTrailingBackSlash(FRuta) + '"';
   ret := ShellExecute(application.MainForm.Handle, nil, 'explorer.exe', PChar(cmd), nil, SW_NORMAL);
   if ret >= HINSTANCE_ERROR then
      result := -1
   else
      result := 0;
end;


//  Proc/Fun     : function CopiarAlPortapapeles
//
//  Valor retorno: Integer
//  Parametros   : Vacio
//
//  Comentarios  : Acción de copiar un archivo al portapapeles
//                 Adaptado a Delphi sobre una idea de James Crowley en
//                 Visual Basic, en un foro  de VB en Internet.
//
function TArchivo.CopiarAlPortapapeles: integer;
const
   gmem_c = GMEM_MOVEABLE OR GMEM_ZEROINIT;
type
   TDROPFILES = record
     pFiles: DWORD;
     pt: TPOINT;
     fNC: LongBool;
     fWide: LongBool;
   end;
var
   s: String;
   i, j: Integer;

   hh: LongInt;
   phh: ^LongInt;
   df: TDROPFILES;

begin
   FillChar(df, SizeOf(df), #0);
   result := -1;
   if OpenClipBoard(0) then
      try
         EmptyClipBoard;

         s:= NombreCompleto + #0#0;

         i := length(s);
         j := SizeOf(df);

         hh:= GlobalAlloc(gmem_c, i + j);
         if hh <> 0 then
         begin
            try

               phh:= GlobalLock(hh);
               try
                  df.pFiles := j;
                  CopyMemory(phh, @df, j);
                  phh := Pointer(LongInt(phh) + j);
                  CopyMemory(phh, PChar(s), i);
               finally
                  GlobalUnlock(hh);
               end;

               if SetClipBoardData(CF_HDROP, hh) <> 0 then
                  result := 0;
            finally
               GlobalFree(hh);
            end;
         end;
      finally
         CloseClipBoard;
      end;
end;


//  Proc/Fun     : function MostrarPropiedades
//
//  Valor retorno: Integer
//  Parametros   : Vacío
//
//  Comentarios  : Lanzamos el cuadro de propiedades del archivo seleccionado
//
function TArchivo.MostrarPropiedades: integer;
var
   s: String;
   shExInfo: TShellExecuteInfo;
begin
   s:= NombreCompleto + #0;

   FillChar(shExInfo, SizeOf(shExInfo), #0);
   shExInfo.cbSize := SizeOf(TShellExecuteInfo);
   shExInfo.fMask  := SEE_MASK_INVOKEIDLIST;
   shExInfo.Wnd    := application.MainForm.Handle;
   shExInfo.lpVerb := 'properties';
   shExInfo.lpFile := PChar(s);

   if ShellExecuteEx(@shExInfo) then
      result := 0
   else
      result := -1;
end;

end.
