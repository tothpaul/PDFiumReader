unit PDFium.SearchDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TSearchDlg = class(TForm)
    edSearch: TEdit;
    btPrev: TButton;
    btNext: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btNextClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    class procedure Execute(Sender: TComponent);
  end;

var
  SearchDlg: TSearchDlg;

implementation

{$R *.dfm}

uses PDFium.Frame;

procedure TSearchDlg.btNextClick(Sender: TObject);
begin
  if not TPDFiumFrame(Owner).Search(edSearch.Text, Sender = btNext) then
    ShowMessage('Text not found');
end;

class procedure TSearchDlg.Execute(Sender: TComponent);
begin
  if SearchDlg = nil then
    SearchDlg := TSearchDlg.Create(Sender)
  else
    SearchDlg.Show;
end;

procedure TSearchDlg.FormDestroy(Sender: TObject);
begin
  SearchDlg := nil;
end;

procedure TSearchDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
        Close;
    VK_RETURN:
        btNextClick(btNext);
  end;
end;

end.
