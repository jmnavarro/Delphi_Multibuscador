program MultiFind;

uses
  Forms,
  main in 'main.pas' {MainForm},
  AnadirRuta in 'AnadirRuta.pas' {AnadirRutaForm},
  Archivo in 'Archivo.pas',
  HiloBusqueda in 'buscador\HiloBusqueda.pas',
  Buscador in 'buscador\Buscador.pas',
  IconosAsociados in 'IconosAsociados.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
