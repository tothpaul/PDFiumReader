program PDFiumReader;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainForm},
  PDFium.Frame in 'PDFium.Frame.pas' {PDFiumFrame: TFrame},
  PDFium.Wrapper in 'PDFium.Wrapper.pas',
  DynamicButtons in 'DynamicButtons.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
