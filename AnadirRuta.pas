//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
//
// Programa: MultiFind
//
// Propósito Modulo AñadirRuta:
//    El proposito de este modulo es la creación de una ventana modal de
//    selección o adición de ruta. El usuario tiene la oportunidad de introducir
//    manualmente los parametros de la busqueda (ruta y token) o bien seleccionarlos
//    del cuadro emergente (pulsación del boton Examinar)
//
//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
unit AnadirRuta;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
   TModoVentana = (mvAnadir, mvModificar);

  TAnadirRutaForm = class(TForm)
    s: TShape;
    b_cancelar: TButton;
    b_aceptar: TButton;
    Label1: TLabel;
    e_carpeta: TEdit;
    Label2: TLabel;
    e_mascara: TEdit;
    cbx_subcarpetas: TCheckBox;
    Panel1: TPanel;
    i_carpeta: TImage;
    procedure i_carpetaClick(Sender: TObject);

    private
      function  GetCarpeta: string;
      procedure SetCarpeta(value: string);
      function  GetMascara: string;
      procedure SetMascara(value: string);
      function  GetSubcarpetas: boolean;
      procedure SetSubcarpetas(value: boolean);

      procedure SetModoVentana(value: TModoVentana);

    public
      property Carpeta: string read GetCarpeta write SetCarpeta;
      property Mascara: string read GetMascara write SetMascara;
      property Subcarpetas: boolean read GetSubcarpetas write SetSubcarpetas;
      property Modo: TModoVentana write SetModoVentana;
  end;

implementation

{$R *.DFM}

uses FileCtrl;


//
// Se incluye un módulo donde se definen funciones para compatibilidad.
//
{$I compatible.inc}



//  Proc/Fun     : procedure i_carpetaClick
//
//  Valor retorno: vacio
//  Parametros   : Sender: TObject
//
//  Comentarios  : Pulsación del cuadro Examinar (visualiza una carpeta).
//                 Abre una ventana modal de selección de directorio.
//
procedure TAnadirRutaForm.i_carpetaClick(Sender: TObject);
var
   dir: string;
begin
   if SelectDirectory('Selecciona la ruta de búsqueda:', '', dir) then
      e_carpeta.text := IncludeTrailingBackSlash(dir);
end;


//  Proc/Fun     : function GetCarpeta
//
//  Valor retorno: string
//  Parametros   : vacio
//
//  Comentarios  : Método de lectura de la propiedad Carpeta
//
function  TAnadirRutaForm.GetCarpeta: string;
begin
   if Pos('*', e_carpeta.text) = 0 then
      result := e_carpeta.text
   else
      result := ExtractFilePath(e_carpeta.text);
end;


//  Proc/Fun     : procedure SetCarpeta
//
//  Valor retorno: vacio
//  Parametros   : value: string
//
//  Comentarios  : Método de escritura de la propiedad Carpeta
//
procedure TAnadirRutaForm.SetCarpeta(value: string);
begin
   e_carpeta.text := value;
end;


//  Proc/Fun     : function  GetMascara
//
//  Valor retorno: string
//  Parametros   : vacío
//
//  Comentarios  : Método de lectura de la propiedad Máscara
//
function  TAnadirRutaForm.GetMascara: string;
begin
   result := e_mascara.text;
end;


//  Proc/Fun     : procedure SetMascara
//
//  Valor retorno: vacío
//  Parametros   : value: string
//
//  Comentarios  : Método de escritura de la propiedad Máscara
//
procedure TAnadirRutaForm.SetMascara(value: string);
begin
   e_mascara.text := value;
end;


//  Proc/Fun     : function  GetSubcarpetas
//
//  Valor retorno: Boolean
//  Parametros   : Vacío
//
//  Comentarios  : Metodo de lectura de la propiedad Subcarpetas
//
function  TAnadirRutaForm.GetSubcarpetas: boolean;
begin
   result := cbx_subcarpetas.checked;
end;


//  Proc/Fun     : procedure SetSubcarpetas
//
//  Valor retorno: Vacío
//  Parametros   : value: boolean
//
//  Comentarios  : Método de escritura de la propiedad Subcarpetas
//
procedure TAnadirRutaForm.SetSubcarpetas(value: boolean);
begin
   cbx_subcarpetas.checked := value;
end;


//  Proc/Fun     : procedure SetModoVentana
//
//  Valor retorno: vacio
//  Parametros   : value: TModoVentana
//
//  Comentarios  : Método de escritura de la propiedad Modo
//                 Hay que tener en cuenta que la ventana puede invocarse tanto
//                 para modificar una ruta como para insertar una nueva
//
procedure TAnadirRutaForm.SetModoVentana(value: TModoVentana);
begin
   case value of
      mvAnadir:    caption := 'Añadir carpeta de búsqueda';
      mvModificar: caption := 'Modificar carpeta de búsqueda';
   end;

end;


end.
