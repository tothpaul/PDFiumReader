program PDFiumReader;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  PDFium.Frame in 'PDFium.Frame.pas' {PDFiumFrame: TFrame},
  DynamicButtons in 'DynamicButtons.pas',
  Execute.libPDFium in 'Execute.libPDFium.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
