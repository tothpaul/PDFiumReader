unit Main;

{
   PDF viewer using libPDFium.dll (c)2017-2018 by Execute SARL
   http://www.execute.fr
   https://github.com/tothpaul/PDFiumReader


}
interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,

  System.SysUtils, System.Variants, System.Classes,

  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.Clipbrd, Vcl.StdCtrls,

  PDFium.Frame;

type
  TMainForm = class(TForm)
    PDFium: TPDFiumFrame;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Quit1: TMenuItem;
    pnButtons: TPanel;
    btZPlus: TPaintBox;
    btZMinus: TPaintBox;
    btOpen: TPaintBox;
    pbZoom: TPaintBox;
    ppZoom: TPopupMenu;
    N101: TMenuItem;
    N251: TMenuItem;
    N501: TMenuItem;
    N1001: TMenuItem;
    N1002: TMenuItem;
    N1251: TMenuItem;
    N1501: TMenuItem;
    N2001: TMenuItem;
    N4001: TMenuItem;
    N8001: TMenuItem;
    N16001: TMenuItem;
    N24001: TMenuItem;
    N32001: TMenuItem;
    N64001: TMenuItem;
    N2: TMenuItem;
    mnActualSize: TMenuItem;
    mnFitWidth: TMenuItem;
    mnPageLevel: TMenuItem;
    btPageWidth: TPaintBox;
    btFullPage: TPaintBox;
    btActualSize: TPaintBox;
    btAbout: TPaintBox;
    Close1: TMenuItem;
    btNext: TPaintBox;
    btPrev: TPaintBox;
    edPage: TEdit;
    lbPages: TLabel;
    shPage: TShape;
    pnPages: TPanel;
    Edit1: TMenuItem;
    Copy1: TMenuItem;
    btPrint: TPaintBox;
    procedure Open1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonMouseLeave(Sender: TObject);
    procedure ButtonPaint(Sender: TObject);
    procedure ButtonMouseEnter(Sender: TObject);
    procedure pbZoomPaint(Sender: TObject);
    procedure pbZoomMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ppZoomPopup(Sender: TObject);
    procedure btZPlusClick(Sender: TObject);
    procedure MenuZoomClick(Sender: TObject);
    procedure mnPageLevelClick(Sender: TObject);
    procedure mnFitWidthClick(Sender: TObject);
    procedure PDFiumResize(Sender: TObject);
    procedure mnActualSizeClick(Sender: TObject);
    procedure btAboutClick(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure pnPagesResize(Sender: TObject);
    procedure btPrevClick(Sender: TObject);
    procedure btNextClick(Sender: TObject);
    procedure edPageExit(Sender: TObject);
    procedure edPageKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Copy1Click(Sender: TObject);
    procedure btPrintClick(Sender: TObject);
  private
    { Déclarations privées }
    FButtons  : TBitmap;
    FFocus    : TPaintBox;
    procedure CreateButtons;
    procedure LoadFile(const AFileName: string);
    procedure OnPDFiumPaint(Sender: TObject);
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DynamicButtons;

resourcestring
  sPDFFiler  = 'Adobe PDF files (*.pdf)|*.pdf';
  sPDFPrompt = 'Open';

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.Title := Caption;
  FButtons := TBitmap.Create;
  CreateButtons;
  PDFium.OnPaint := OnPDFiumPaint;
  if ParamCount = 1 then
    LoadFile(ParamStr(1));
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FButtons.Free;
end;

procedure TMainForm.LoadFile(const AFileName: string);
begin
  PDFium.LoadFromFile(AFileName);
  PDFium.SetFocus();
  Caption := ExtractFileName(AFileName) + ' - ' + Application.Title;
  pnPages.Visible := PDFium.PageCount > 1;
end;

procedure TMainForm.MenuZoomClick(Sender: TObject);
begin
  PDFium.ZoomMode := zmCustom;
  PDFium.Zoom := TComponent(Sender).Tag;
end;

procedure TMainForm.mnActualSizeClick(Sender: TObject);
begin
  PDFium.ZoomMode := zmCustom;
  PDFium.Zoom := 100;
end;

procedure TMainForm.mnFitWidthClick(Sender: TObject);
begin
  PDFium.ZoomMode := zmPageWidth;
end;

procedure TMainForm.mnPageLevelClick(Sender: TObject);
begin
  PDFium.ZoomMode := zmPageLevel;
end;

procedure TMainForm.ButtonPaint(Sender: TObject);
var
  D, S: TRect;
  I: Integer;
begin
  D := TPaintBox(Sender).ClientRect;
  S := TRect.Create(0, 0, 24, 24);
  I := TPaintBox(Sender).Tag;
  if (Sender = FFocus) and (Odd(I) = False) then
    Inc(I);
  S.Offset(24 * I, 0);
  with TPaintBox(Sender).Canvas do
  begin
    CopyRect(D, FButtons.Canvas, S);
  end;
end;

procedure TMainForm.btAboutClick(Sender: TObject);
begin
  ShellExecute(0, nil, 'http://www.execute.fr', nil, nil, SW_SHOW);
end;

procedure TMainForm.btNextClick(Sender: TObject);
begin
  PDFium.NextPage;
end;

procedure TMainForm.btPrevClick(Sender: TObject);
begin
  PDFium.PrevPage;
end;

procedure TMainForm.btPrintClick(Sender: TObject);
begin
  PDFium.Print();
end;

procedure TMainForm.btZPlusClick(Sender: TObject);
var
  Zoom : Integer;
  Z1   : Integer;
  Z2   : Integer;
  Zx   : Integer;
  Index: Integer;
begin
  Z1 := 1000;
  Z2 := 640000;
  Zoom := Round(PDFium.Zoom * 100);
  for Index := 0 to ppZoom.Items.count - 1 do
  begin
    Zx := 100 * ppZoom.Items[Index].Tag;
    if Zx <> 0 then
    begin
      if (Zx < Zoom) and (Zx > Z1) then
        Z1 := Zx
      else
      if (Zx > Zoom) and (Zx < Z2) then
        Z2 := Zx;
    end;
  end;
  if Sender = btZPlus then
    Z1 := Z2;
  PDFium.ZoomMode := zmCustom;
  PDFium.Zoom := Z1/100;
  pbZoom.Invalidate;
end;

procedure TMainForm.ButtonMouseEnter(Sender: TObject);
begin
  if Sender = FFocus then
    Exit;
  if FFocus <> nil then
    FFocus.Invalidate;
  FFocus := TPaintBox(Sender);
  if FFocus <> nil then
    FFocus.Invalidate;
end;

procedure TMainForm.ButtonMouseLeave(Sender: TObject);
begin
  if FFocus <> nil then
  begin
    FFocus.Invalidate;
    FFocus := nil;
  end;
end;

procedure TMainForm.Close1Click(Sender: TObject);
begin
  PDFium.CloseDocument;
end;

procedure TMainForm.Copy1Click(Sender: TObject);
begin
  Clipboard.AsText := PDFium.GetSelectionText;
end;

procedure TMainForm.CreateButtons;
begin
  FButtons.PixelFormat := pf32Bit;
  FButtons.SetSize(2 * 2 * 10 * 24, 2 * 24);
  with FButtons.Canvas do
  begin
    Brush.Color := clBtnFace;
    FillRect(Rect(0, 0, FButtons.Width, FButtons.Height));

    Pen.Width := 4;
    DrawButtons( 0, $6F6F6F);
    DrawButtons(48, $C87521);
  end;
//  FButtons.SaveToFile('BUTTONS48.BMP');
  AntiAliaze(FButtons);
  with FButtons.Canvas do
  begin
    Pen.Width := 1;
    FixButtons( 0, $6F6F6F);
    FixButtons(24, $C87521);
  end;
//  FButtons.SaveToFile('BUTTONS24.BMP');
end;

procedure TMainForm.edPageExit(Sender: TObject);
begin
  edPage.Text := IntToStr(PDFium.PageIndex + 1);
end;

procedure TMainForm.edPageKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Page: Integer;
  Msg: TMsg;
begin
  if Key = VK_RETURN then
  begin
    if TryStrToInt(edPage.Text, Page) then
    begin
      PDFium.GoPage(Page - 1);
    end;
    Key := 0;
    PeekMessage(Msg, 0, WM_CHAR, WM_CHAR, PM_REMOVE);
  end;
end;

procedure TMainForm.OnPDFiumPaint(Sender: TObject);
begin
  edPage.Text := IntToStr(PDFium.PageIndex + 1);
  lbPages.Caption := Format('(%d / %d)', [PDFium.PageIndex + 1, PDFium.PAgeCount]);
end;

procedure TMainForm.Open1Click(Sender: TObject);
var
  Str: string;
begin
  Str := '';
  if PromptForFileName(Str, sPDFFiler, sPDFPrompt) then
  begin
    LoadFile(Str);
  end;
end;

procedure TMainForm.pbZoomMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
begin
  if Button = mbLeft then
  begin
    p.x := x;
    p.y := y;
    p := pbZoom.ClientToScreen(p);
    ppZoom.Popup(p.x, p.y);
  end;
end;

procedure TMainForm.pbZoomPaint(Sender: TObject);
var
  Str: string;
  R  : TRect;
begin
  R := pbZoom.ClientRect;
  with pbZoom.Canvas do
  begin
    Pen.Color := $CBCBCB;
    Brush.Color := clWhite;
    Rectangle(R);
    if FFocus = Sender then
    begin
      Pen.Color := $D28E4A;
      Brush.Color := $C87521;
    end else begin
      Pen.Color := $8A8A8A;
      Brush.Color := $6F6F6F;
    end;
    Arrow(60, 12);
    Dec(R.Right, 24);
    Str := FloatToStrF(PDFium.Zoom, TFloatFormat.ffFixed, 18, 0) + '%';
    Brush.Color := clWhite;
    Font.Color := $4D4D4D;
    TextRect(R, Str, [TTextFormats.tfSingleLine, TTextFormats.tfCenter, TTextFormats.tfVerticalCenter]);
  end;
end;

procedure TMainForm.PDFiumResize(Sender: TObject);
begin
  btPageWidth.Tag := 6 + Ord(PDFium.ZoomMode = zmPageWidth);
  btFullPage.Tag := 8 + Ord(PDFium.ZoomMode = zmPageLevel);
  btActualSize.Tag := 10 + Ord((PDFium.ZoomMode = zmCustom) and (Round(PDFium.Zoom * 100) = 10000));
  pnButtons.Invalidate;
end;

procedure TMainForm.pnPagesResize(Sender: TObject);
begin
  shPAge.SetBounds(edPage.Left, edPage.Top + edPage.Height + 1, edPage.Width, 1);
end;

procedure TMainForm.ppZoomPopup(Sender: TObject);
var
  Zoom : Integer;
  Index: Integer;
begin
  Zoom := Round(PDFium.Zoom * 100);
  for Index := 0 to ppZoom.Items.Count - 1 do
  begin
    ppZoom.Items[Index].Checked := (PDFium.ZoomMode = zmCustom) and (ppZoom.Items[Index].Tag * 100 = Zoom);
  end;
  mnActualSize.Checked := (PDFium.ZoomMode = zmCustom) and (Zoom = 10000);
  mnPageLevel.Checked := PDFium.ZoomMode = zmPageLevel;
  mnFitWidth.Checked := PDFium.ZoomMode = zmPageWidth;
end;

procedure TMainForm.Quit1Click(Sender: TObject);
begin
  Close();
end;

end.
