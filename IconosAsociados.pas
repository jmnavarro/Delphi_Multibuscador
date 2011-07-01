//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//
// Programa: MultiFind
//
// Propósito Modulo IconosAsociados:
//    Definir un descendiente de TImageList que gestione la recuperación de iconos asociados
//    controlando almacenar un solo icono por cada tipo, y reutilizando este icono
//    para mostrarlo cuando sea necesario. 
//
//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
unit IconosAsociados;

interface

uses controls, windows, classes, graphics, imgList;

type
   //
   // Esta clase representa un icono (HIcon) asociado a una extensión concreta
   //
   TIconoAsociado = class(TObject)
   private
      FHandle: HICON;
      FExtension: ShortString;

   public
      constructor Create(filename: ShortString); overload;
      constructor Create(ico: TIconoAsociado); overload; // copy-constructor
      destructor Destroy; override;

      // Retorna un HICON asociado a un archivo (del proyecto JEDI)
      class function GetFileTypeIcon(const Filename: string; UsarAtributos: Boolean): HICON;

      property Handle: HICON read FHandle;
      property Extension: ShortString read FExtension;
   end;


   //
   // Esta clase representa una lista de iconos asociados a sus extensiones
   // (objetos de tipo TIconoAsociado)
   //
   TListaIconosAsociados = class(TStringList)
   public
      destructor Destroy; override;

      function AddIcon(ico: TIconoAsociado): integer;
   end;

   //
   // Esta clase es un descendiente de TImageList que gestiona la recuperación de iconos
   // asociados de archivos.
   // Sigue el patrón "pool"
   //
   TIconosAsociados = class(TImageList)
   private
      FAsociados: TListaIconosAsociados;

   public
      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      function AddIconoAsociado(const Filename: ShortString): TImageIndex;
   end;


implementation

uses ShellAPI, SysUtils;


//  Proc/Fun   : TIconoAsociado.Create
//
//  Parametros : filename: string
//
//  Comentarios: Crea un nuevo icono asociado, obteniendo el handle del icono
//
constructor TIconoAsociado.Create(filename: ShortString);
var
   ext: ShortString;
begin
   inherited Create;

   ext := ExtractFileExt(filename);
   System.Delete(ext, 1, 1);

   self.FExtension := ext;
   self.FHandle    := GetFileTypeIcon(filename, true);
end;


//  Proc/Fun   : TIconoAsociado.Create
//
//  Parametros : ico: TIconoAsociado
//
//  Comentarios: Crea un icono a partir de los datos de otro.
//               Sigue el patrón "copy-constructor"
//
constructor TIconoAsociado.Create(ico: TIconoAsociado); // copy-constructor
begin
   inherited Create;

   self.FExtension := ico.FExtension;
   self.FHandle    := ico.FHandle;
end;


//  Proc/Fun:    TIconoAsociado.Destroy
//
//  Comentarios: Libera el objeto TIconoAsociado y el descriptor HICON
//
destructor TIconoAsociado.Destroy;
begin
   if FHandle <> 0 then
      DestroyIcon(FHandle);

   inherited;
end;


//  Proc/Fun     : class function TIconoAsociado.GetFileTypeIcon()
//
//  Valor retorno: HICON
//  Parametros   : const Filename: string; UsarAtributos: Boolean
//
//  Comentarios  : Crea un descriptor de tipo HICON que representa el icono (16x16)asociado a
//                 una extensión. Este descriptor debe destruírse con DestroyIcon.
//
class function TIconoAsociado.GetFileTypeIcon(const Filename: string; UsarAtributos: Boolean): HICON;
var
  FileInfo: TSHFileInfo;
  flags: Cardinal;
begin
   FillChar(FileInfo, sizeof(TSHFileInfo), 0);

   flags := SHGFI_ICON or SHGFI_SMALLICON;
   if UsarAtributos then
      flags := flags or SHGFI_USEFILEATTRIBUTES;

   SHGetFileInfo(PChar(Filename), 0, FileInfo, sizeof(TShFileInfo), flags);
   result := FileInfo.hIcon;
end;




//  Proc/Fun     : destructor TListaIconosAsociados.Destroy
//
//  Comentarios  : Destruye la lista y los objetos contenidos en la lista
//
destructor TListaIconosAsociados.Destroy;
var
   icoAs: TIconoAsociado;
   i: integer;
begin
   for i := Pred(self.Count) downto 0 do
   begin
      icoAs := TIconoAsociado(self.Objects[i]);
      icoAs.Free;
   end;

   self.Clear;

   inherited;
end;


//  Proc/Fun     : function TListaIconosAsociados.AddIcon
//
//  Valor retorno: integer
//  Parametros   : ico: TIconoAsociado
//
//  Comentarios  : Añade un nuevo icono a la lista
//
function TListaIconosAsociados.AddIcon(ico: TIconoAsociado): integer;
begin
   result := self.AddObject(ico.Extension, ico);
end;




//  Proc/Fun     : constructor TIconosAsociados.Create
//
//  Parametros   : AOwner: TComponent
//
//  Comentarios  : Crea el ImageList y da valores iniciales
//
constructor TIconosAsociados.Create(AOwner: TComponent);
begin
   inherited;

   self.Width  := 16;
   self.Height := 16;
   self.ShareImages := true;

   FAsociados := TListaIconosAsociados.Create;
end;

destructor TIconosAsociados.Destroy;
begin
   FAsociados.Free;

   inherited;
end;



//  Proc/Fun     : function TIconosAsociados.AddIconoAsociado()
//
//  Valor retorno: TImageIndex
//  Parametros   : const Filename: ShortString
//
//  Comentarios  : Busca si el icono asociado a "Filename" ya existe, retornándolo o
//                 creando uno nuevo en caso de que no exista.
//
function TIconosAsociados.AddIconoAsociado(const Filename: ShortString): TImageIndex;
var
   ind: integer;
   ico: TIcon;
   icoAso: TIconoAsociado;
   ext: ShortString;
begin
   ext := AnsiLowercase(ExtractFileExt(filename));
   System.Delete(ext, 1, 1);

   // comprobar si este ya ha sido insertado
   // Se excluyen aquellos tipos que tienen que mostrar un icono distinto por
   // cada archivo, es decir: los programas y los iconos.

   if (ext = 'exe') or (ext = 'ico') then
      ind := -1
   else
      ind := FAsociados.IndexOf(ext);
      
   if ind = -1 then
   begin
      icoAso := TIconoAsociado.Create(filename);

      ico := TIcon.Create;
      try
         ico.Handle := icoAso.Handle;
         ind := self.AddIcon(ico);
      finally
         ico.Free;
      end;

      // añadir a la lista de asociados.
      FAsociados.AddIcon(icoAso);
   end;

   result := ind;
end;


end.

