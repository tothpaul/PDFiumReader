unit PDFium.PrintDlg;

interface
{$WARN WIDECHAR_REDUCED OFF}
uses
  Winapi.Windows, Winapi.Messages, Winapi.Winspool,
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.WinXPanels,
  Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.Tabs, Vcl.Printers, PDFium.Frame;

type
  TPrintDlg = class(TForm)
    Panel1: TPanel;
    LabelImprimante: TLabel;
    LabelCopies: TLabel;
    cbPrinters: TComboBox;
    btProperties: TButton;
    seCopies: TSpinEdit;
    cbGrouped: TCheckBox;
    cbAnnotations: TCheckBox;
    Panel6: TPanel;
    btCancel: TButton;
    btPrint: TButton;
    Panel2: TPanel;
    PaintBox: TPaintBox;
    lbScale: TLabel;
    lbPageSize: TLabel;
    btFirst: TButton;
    btPrev: TButton;
    btLast: TButton;
    btNext: TButton;
    edPage: TEdit;
    Panel3: TPanel;
    Panel5: TPanel;
    CardPanel1: TCardPanel;
    CardEchelle: TCard;
    Label6: TLabel;
    rbScale: TRadioButton;
    rbRealSize: TRadioButton;
    rbReduice: TRadioButton;
    rbCustomScale: TRadioButton;
    edCustomScale: TEdit;
    cdMulti: TCard;
    LabelpagesparFeuilles: TLabel;
    LabelOrdrePages: TLabel;
    cbSheets: TComboBox;
    cbPageOrder: TComboBox;
    cbPageContour: TCheckBox;
    Panel7: TPanel;
    LabelpagesImprimer: TLabel;
    Labelimpairespaires: TLabel;
    rbAllPages: TRadioButton;
    rbCurrentPage: TRadioButton;
    rbCustomPages: TRadioButton;
    edPages: TEdit;
    cbOddPages: TComboBox;
    Panel8: TPanel;
    LabelOrientation: TLabel;
    Labelrectoverso: TLabel;
    rbAuto: TRadioButton;
    rbPortrait: TRadioButton;
    rbLandscape: TRadioButton;
    cbRectoVerso: TComboBox;
    cbGrayscale: TCheckBox;
    cbCenter: TCheckBox;
    Panel4: TPanel;
    Shape1: TShape;
    tabScale: TLabel;
    tabPageLayout: TLabel;
    tabShape: TShape;
    procedure FormCreate(Sender: TObject);
    procedure cbPrintersChange(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure btPropertiesClick(Sender: TObject);
    procedure cbAnnotationsClick(Sender: TObject);
    procedure rbAllPagesClick(Sender: TObject);
    procedure edPagesChange(Sender: TObject);
    procedure cbOddPagesChange(Sender: TObject);
    procedure cbRectoVersoChange(Sender: TObject);
    procedure rbAutoClick(Sender: TObject);
    procedure cbGrayscaleClick(Sender: TObject);
    procedure cbCenterClick(Sender: TObject);
    procedure rbScaleClick(Sender: TObject);
    procedure edCustomScaleChange(Sender: TObject);
    procedure edCustomScaleExit(Sender: TObject);
    procedure cbSheetsChange(Sender: TObject);
    procedure cbPageOrderChange(Sender: TObject);
    procedure cbPageContourClick(Sender: TObject);
    procedure btNavigate(Sender: TObject);
    procedure edPageChange(Sender: TObject);
    procedure edPageExit(Sender: TObject);
    procedure CardPanel1CardChange(Sender: TObject; PrevCard, NextCard: TCard);
    procedure tabScaleClick(Sender: TObject);
    procedure btPrintClick(Sender: TObject);
  private
    { Déclarations privées }
    FPDFFrame: TPDFiumFrame;
    FOptions: TPDFPrintOptions;
    FPrintScale: Single;
    procedure GetPaperSize(Device, Port: PChar; DevMode: PDeviceMode);
    function IsLandscape: Boolean;
    procedure ResizePreview;
    procedure ComputeScale();
    procedure GetPrinterSize(var Width, Height: Integer);
    procedure OnPageNumber;
    procedure ComputePages;
  public
    { Déclarations publiques }
    class procedure Execute(Sender: TPDFiumFrame);
  end;

var
  PrintDlg: TPrintDlg;

implementation

{$R *.dfm}

procedure Blanks(const Str: string; var Index: Integer);
begin
  while Str[Index] in [#9, ' '] do
    Inc(Index);
end;

function GetNum(const Str: string; var Index, Value: Integer): Boolean;
begin
  Result := Str[Index] in ['0'..'9'];
  if Result then
  begin
    Value := 0;
    repeat
      Value := 10 * Value + Ord(Str[Index]) - Ord('0');
      Inc(Index);
    until not (Str[Index] in ['0'..'9']);
  end;
end;

function GetRange(const Str: string; var Index, First, Last: integer): Boolean;
begin
  while not (Str[Index] in [#0, '0'..'9']) do
    Inc(Index);
  Result := GetNum(Str, Index, First);
  if Result then
  begin
    Blanks(Str, Index);
    if Str[Index] = '-' then
    begin
      Inc(Index);
      if not GetNum(Str, Index, Last) then
        Last := MaxInt;
    end else begin
      Last := First;
    end;
  end;
end;

{ TPrintDlg }

procedure TPrintDlg.btNavigate(Sender: TObject);
begin
  case TButton(Sender).Tag of
    -2: FOptions.PageNumber := 1;
    -1: Dec(FOptions.PageNumber, FOptions.PagePerSheet);
    +1: Inc(FOptions.PageNumber, FOptions.PagePerSheet);
    +2: FOptions.PageNumber := Length(FOptions.Pages) - FOptions.PagePerSheet + 1;
  end;
  OnPageNumber;
  ResizePreview;
  PaintBox.Invalidate;
end;

procedure TPrintDlg.btPrintClick(Sender: TObject);
type
  // One point is 1/72 inch (around 0.3528 mm).
  TPointsSize = record
    cx: Single;
    cy: Single;
  end;
var
  duplex: Boolean;
  copies: Boolean;
  collate: Boolean;
  device: array[0..255] of char;
  driver: array[0..255] of char;
  port: array[0..255] of char;
  hDMode: THandle;
  pDMode: PDEVMODE;
  Rect: TRect;
  Options: TPDFPrintOptions;
  sx, sy: Single;
//  iPrints: Integer;
  nPrints: Integer;
  iCopies: Integer;
  nCopies: Integer;
  iPrint: Integer;
  pw, ph: Integer;
  s1, s2: Single;
  Size  : TPointsSize;
begin
  nPrints := 1;
  nCopies := 1;
  Printer.GetPrinter(device, driver, port, hDMode);
  if (hDMode <> 0) then
  begin
    duplex := DeviceCapabilities(Device, Port, DC_DUPLEX, nil, nil) = 1;
    copies := DeviceCapabilities(Device, Port, DC_COPIES, nil, nil) > 1;
    collate := DeviceCapabilities(Device, Port, DC_COLLATE, nil, nil) = 1;
    pDMode := GlobalLock(hDMode);
    if Assigned(pDMode) then
    begin
      if copies then
      begin
        pDMode.dmFields := pDMode.dmFields or DM_COPIES;
        pDMode.dmCopies := seCopies.Value;
        if collate then
        begin
          pDMode.dmFields := pDMode.dmFields or DM_COLLATE;
          if cbGrouped.Checked then
            pDMode.dmCollate := DMCOLLATE_TRUE
          else
            pDMode.dmCollate := DMCOLLATE_FALSE;
        end;
      end else begin
        if cbGrouped.Checked then
        begin
          nPrints := seCopies.Value;
          nCopies := 1;
        end else begin
          nPrints := 1;
          nCopies := seCopies.Value;
        end;
      end;
      if duplex then
      begin
        pDMode.dmFields := pDMode.dmFields or DM_DUPLEX;
        case cbRectoVerso.ItemIndex of
          0: pDMode.dmDuplex := DMDUP_SIMPLEX;
          1: pDMode.dmDuplex := DMDUP_VERTICAL;
          2: pDMode.dmDuplex := DMDUP_HORIZONTAL;
        end;
      end;
      GlobalUnlock(hDMode);
    end;
  end;

  Options := FOptions;

  Printer.BeginDoc;

  // problème d'initialisation du Job ?
  if Printer.Printing = False then
  begin
    Exit;
  end;

  Rect := TRect.Create(0, 0, Printer.PageWidth, Printer.PageHeight);

  // Rect est exprimé en pixels dans la résolution de l'imprimange
  // il faut appliquer un facteur d'échelle sur les dimensions du PDF en 1/72 de pouce
  sx := GetDeviceCaps(Printer.Handle, LOGPIXELSX)/72;
  sy := GetDeviceCaps(Printer.Handle, LOGPIXELSY)/72;

 // Taille de la page en pixels dans la résolution de l'imprimante
  pw := Printer.PageWidth;
  ph := Printer.PageHeight;

  for iPrint := 1 to nPrints do
  begin
    Options.PageNumber := 1;
    while Options.PageNumber <= Length(Options.Pages) do
    begin
      if (Options.PageNumber > 1) or (iPrint > 1) then
        Printer.NewPage;
      for iCopies := 1 to nCopies do
      begin
        if iCopies > 1 then
          Printer.NewPage;
        Size.cx :=  FPDFFrame.PageWidth(Options.CurrentPage);
        Size.cy :=  FPDFFrame.PageHeight(Options.CurrentPage);
        if IsLandscape then
        begin
          s1 := Size.cx;
          Size.cx := Size.cy;
          Size.cy := s1;
          Options.Rotation := 1
        end else begin
          Options.Rotation := 0;
        end;

        if Options.PageSize in [0, 2] then
        begin
        // Ramener la taille en pouces par rapport à la taille de la page en pouces
          s1 := pw / (sx * Size.cx);
          s2 := ph / (sy * Size.cy);
          if s2 < s1 then
            s1 := s2;
        // Réduire les pages hors format
          if (Options.PageSize = 2) and (s1 > 1) then
            s1 := 1;
        // Echelle finale
          Options.PageScale := s1;
        end;

        FPDFFrame.PrintPreview(Printer.Canvas, Rect, Options, sx, sy, True);
      end;
      Inc(Options.PageNumber, Options.PagePerSheet);
    end;
  end;

  Printer.EndDoc;
end;

procedure TPrintDlg.btPropertiesClick(Sender: TObject);
var
  device: array[0..255] of char;
  driver: array[0..255] of char;
  port: array[0..255] of char;
  hDMode: THandle;
  pDMode: PDEVMODE;
  hPrinter: THandle;
begin
  Printer.PrinterIndex := Printer.PrinterIndex;
  Printer.GetPrinter(device, driver, port, hDMode);
  if (hDMode <> 0) then
  begin
    pDMode := GlobalLock(hDMode);
    if Assigned(pDMode) then
    begin
      try
        if OpenPrinter(device,hPrinter,nil) then
        begin
          try
            if DocumentProperties(Handle, hPrinter, device, pDMode^, pDMode^, DM_IN_PROMPT or DM_OUT_BUFFER or DM_IN_BUFFER) = IDOK then
            begin
              GetPaperSize(device, port, pDMode);
            end;
          finally
//            Printer.PrinterIndex := Printer.PrinterIndex;
            ClosePrinter(hPrinter);
          end;
        end;
      finally
        GlobalUnlock(hDMode);
      end;
    end;
    Printer.SetPrinter(device, driver, port, hDMode);
  end;
//  cbPrintersChange(Self);
  ResizePreview();
  PaintBox.Repaint;
end;

procedure TPrintDlg.CardPanel1CardChange(Sender: TObject; PrevCard,
  NextCard: TCard);
begin
  if FOptions.PageCount = 0 then
    Exit;
  if NextCard = cdMulti then
  begin
    FOptions.PageContour := cbPageContour.Checked;
    cbSheetsChange(Self);
  end else begin
    FOptions.PageContour := False;
    FOptions.PagePerSheet := 1;
    ResizePreview;
    PaintBox.Repaint;
  end;
  OnPageNumber;
end;

procedure TPrintDlg.cbAnnotationsClick(Sender: TObject);
begin
  FOptions.Annotations := cbAnnotations.Checked;
  PaintBox.Invalidate;
end;

procedure TPrintDlg.cbCenterClick(Sender: TObject);
begin
  FOptions.Center := cbCenter.Checked;
  PaintBox.Invalidate;
end;

procedure TPrintDlg.cbGrayscaleClick(Sender: TObject);
begin
  FOptions.GrayScale := cbGrayScale.Checked;
  PaintBox.Invalidate;
end;

procedure TPrintDlg.cbOddPagesChange(Sender: TObject);
begin
  FOptions.PageType := cbOddPages.ItemIndex;
  ComputePages();
  ResizePreview();
  PaintBox.Repaint;
end;

procedure TPrintDlg.cbPageContourClick(Sender: TObject);
begin
  FOptions.PageContour := cbPageContour.Checked;
  PaintBox.Repaint;
end;

procedure TPrintDlg.cbPageOrderChange(Sender: TObject);
begin
  FOptions.PageOrder := cbPageOrder.ItemIndex;
  PaintBox.Repaint;
end;

procedure TPrintDlg.cbPrintersChange(Sender: TObject);
var
  Device, Driver, Port: array[0..79] of Char;
  HDeviceMode: THandle;
  DeviceMode : PDeviceMode;
begin
  Printer.PrinterIndex := cbPrinters.ItemIndex;
  Printer.GetPrinter(Device, Driver, Port, HDeviceMode);
  if HDeviceMode = 0 then
  begin
    Printer.SetPrinter(Device, Driver, Port, HDeviceMode);
    Printer.GetPrinter(Device, Driver, Port, HDeviceMode);
  end;
  if HDeviceMode = 0 then
  begin
    lbPageSize.Caption := 'Unknown page size';
    Exit;
  end;
  DeviceMode := GlobalLock(HDeviceMode);
  if DeviceMode = nil then
  begin
    lbPageSize.Caption := 'Error on page size';
    Exit;
  end;
  GetPaperSize(Device, Port, DeviceMode);
  GlobalUnlock(HDeviceMode);
  ResizePreview();
end;

procedure TPrintDlg.cbRectoVersoChange(Sender: TObject);
begin
  FOptions.PageOrder := cbPageOrder.ItemIndex;
  PaintBox.Repaint;
end;

procedure TPrintDlg.cbSheetsChange(Sender: TObject);
begin
// 2 4 6 9 16
  if TryStrToInt(cbSheets.Text, FOptions.PagePerSheet) = False then
    FOptions.PagePerSheet := 2;
  OnPageNumber();
  ResizePreview();
  PaintBox.Repaint;
end;

procedure TPrintDlg.ComputePages;
var
  Index: Integer;
  Str  : string;
  a, b : Integer;
begin
  FOptions.Pages := nil;
  FOptions.PageCount := FPDFFrame.PageCount;
  if rbCurrentPage.Checked then
  begin
    a := FPDFFrame.PageNumber;
    FOptions.AddPages(a, a);
  end else begin
    if rbCustomPages.Checked then
    begin
      Str := Trim(edPages.Text);
      if Str <> '' then
      begin
        Index := 1;
        while GetRange(Str, Index, a, b) do
        begin
          FOptions.AddPages(a, b);
        end;
      end;
    end else begin
      FOptions.AddPages(1, FOptions.PageCount);
    end;
  end;
  if (FOptions.PageNumber = 0) or (FOptions.PageNumber > Length(FOptions.Pages)) then
    FOptions.PageNumber := 1;
  OnPageNumber;
end;

procedure TPrintDlg.ComputeScale;
var
  w, h: Integer;
  s1, s2: Single;
begin
  if Length(FOptions.Pages) = 0 then
  begin
    FOptions.PageScale := 1;
    Exit;
  end;

// Echelle personnalisée
  if FOptions.PageSize = 3 then
    Exit;

// Taille réelle
  if FOptions.PageSize = 1 then
  begin
    FOptions.PageScale := 1;
    Exit;
  end;

// Taille de la page en pixels dans la résolution de l'imprimante
  GetPrinterSize(w, h);

// Ramener la taille en pouces par rapport à la taille de la page en pouces
  s1 := (w / GetDeviceCaps(Printer.Handle, LOGPIXELSX)) / (FPDFFrame.PageWidth(FOptions.CurrentPage) / 72);
  s2 := (h / GetDeviceCaps(Printer.Handle, LOGPIXELSY)) / (FPDFFrame.PageHeight(FOptions.CurrentPage) / 72);
  if s2 < s1 then
    s1 := s2;

// Réduire les pages hors format
  if (FOptions.PageSize = 2) and (s1 > 1) then
    s1 := 1;

// Echelle finale
  FOptions.PageScale := s1;
end;

procedure TPrintDlg.edCustomScaleChange(Sender: TObject);
var
  Scale: Single;
begin
  if TryStrToFloat(edCustomScale.Text, Scale) and (Scale > 0) then
    FOptions.PageScale := Scale / 100
  else
    FOptions.PageScale := 1;
  ResizePreview();
  PaintBox.Invalidate;
end;

procedure TPrintDlg.edCustomScaleExit(Sender: TObject);
begin
  edCustomScale.Text := Format('%2f', [FOptions.PageScale * 100]);
end;

procedure TPrintDlg.edPageChange(Sender: TObject);
var
  p, e: Integer;
begin
  Val(edPage.Text, p, e);
  p := (p - 1) * FOptions.PagePerSheet + 1;
  if (p > 0) and (p <= Length(FOptions.Pages)) and (p <> FOptions.PageNumber) then
  begin
    FOptions.PageNumber := p;
    PaintBox.Invalidate;
  end;
end;

procedure TPrintDlg.edPageExit(Sender: TObject);
begin
  OnPageNumber();
end;

procedure TPrintDlg.edPagesChange(Sender: TObject);
begin
  OnPageNumber;
  ComputePages();
  ResizePreview();
  PaintBox.Repaint;
end;

class procedure TPrintDlg.Execute(Sender: TPDFiumFrame);
begin
  PrintDlg := TPrintDlg.Create(Sender);
  try
    PrintDlg.ShowModal;
  finally
    PrintDlg.Free;
  end;
end;

procedure TPrintDlg.FormCreate(Sender: TObject);
begin
  FPDFFrame := Owner as TPDFiumFrame;

  FOptions.GrayScale := cbGrayscale.Checked;
  FOptions.Center := cbCenter.Checked;
  FOptions.Annotations := cbAnnotations.Checked;
  FOptions.PageNumber := 1;
  FOptions.PageScale := 1;
  FPrintScale := 1;
  FOptions.PagePerSheet := 1;

  cbPrinters.Items.Assign(Printer.Printers);
  cbPrinters.ItemIndex := Printer.PrinterIndex;

  ComputePages;

  cbPrintersChange(Self);
end;

procedure TPrintDlg.GetPaperSize(Device, Port: PChar; DevMode: PDeviceMode);
var
  Count: Integer;
  Papers: array of SHORT;
  Sizes : array of TPoint;
begin
  FOptions.PaperWidth := DevMode.dmPaperWidth;
  FOptions.PaperHeight := DevMode.dmPaperLength;
  if (DevMode.dmPaperSize <> DMPAPER_USER) and ((DevMode.dmFields and (DM_PAPERLENGTH or DM_PAPERWIDTH)) <> (DM_PAPERLENGTH or DM_PAPERWIDTH)) then
  begin
    Count := DeviceCapabilities(Device, Port, DC_PAPERS, nil, DevMode);
    SetLength(Papers, Count);
    DeviceCapabilities(Device, Port, DC_PAPERS, Pointer(Papers), DevMode);

    Count := DeviceCapabilities(Device, Port, DC_PAPERSIZE, nil, DevMode);
    SetLength(Sizes, Count);
    DeviceCapabilities(Device, Port, DC_PAPERSIZE, Pointer(Sizes), DevMode);

    for Count := 0 to Length(Papers) - 1 do
      if Papers[Count] = DevMode.dmPaperSize then
      begin
        FOptions.PaperWidth := Sizes[Count].X;
        FOptions.PaperHeight := Sizes[Count].Y;
        Break;
      end;
  end;
end;


procedure TPrintDlg.GetPrinterSize(var Width, Height: Integer);
var
  t: Integer;
begin
  Width := Printer.PageWidth;
  Height := Printer.PageHeight;

// Rotation automatique
  if IsLandscape then
  begin
    t := Width;
    Width := Height;
    Height := t;
  end;
end;


function TPrintDlg.IsLandscape: Boolean;
begin
  case FOptions.Orientation of
   1: Result := FOptions.PagePerSheet in [2, 6];
   2: Result := FOptions.PagePerSheet in [1, 4, 9, 16]
  else
    Result := (FOptions.PagePerSheet in [2, 6]) or FPDFFrame.IsLandscape(FOptions.PageNumber);
  end;

end;

procedure TPrintDlg.tabScaleClick(Sender: TObject);
begin
  CardPanel1.ActiveCardIndex := TLabel(Sender).Tag;
  if Sender = tabScale then
  begin
    tabScale.Font.Style := [fsBold];
    tabPageLayout.Font.Style := [];
    tabShape.Left := tabScale.Left;
    tabShape.Width := tabScale.Width;
  end else begin
    tabScale.Font.Style := [];
    tabPageLayout.Font.Style := [fsBold];
    tabShape.Left := tabPageLayout.Left;
    tabShape.Width := tabPageLayout.Width;
  end;
end;

procedure TPrintDlg.OnPageNumber;
var
  Str: string;
  pn : Integer;
  nb : Integer;
begin
  pn := (FOptions.PageNumber - 1 + FOptions.PagePerSheet - 1) div FOptions.PagePerSheet + 1;
  nb := (Length(FOptions.Pages) + FOptions.PagePerSheet - 1) div FOptions.PagePerSheet;
  if pn > nb then
    pn := nb;
  FOptions.PageNumber := (pn - 1) * FOptions.PagePerSheet + 1;
  Str := IntToStr(pn) + '/' + IntToStr(nb);
  if pn <> FOptions.CurrentPage then
    Str := Str + ' (' + IntToStr(FOptions.CurrentPage) + ')';
  if Str <> edPage.Text then
    edPage.Text := Str;
  btFirst.Enabled := FOptions.PageNumber > 1;
  btLast.Enabled := pn < nb;
  btPrev.Enabled := btFirst.Enabled;
  btNext.Enabled := btLast.Enabled;
end;

procedure TPrintDlg.PaintBoxPaint(Sender: TObject);
var
  r : TRect;
  p : TRect;
  sx, sy: Single;
  w, h : Integer;
begin
// Taille du papier à l'écran
  r := PaintBox.ClientRect;

// Zone d'impression en résolution d'impression
  GetPrinterSize(w, h);

// résolution imprimante vers résolution écran
  sx := FPrintScale * Screen.PixelsPerInch / GetDeviceCaps(Printer.Handle, LOGPIXELSX);
  sy := FPrintScale * Screen.PixelsPerInch / GetDeviceCaps(Printer.Handle, LOGPIXELSY);

// Zone d'impression à l'écran
  p.Top := Round(GetDeviceCaps(Printer.Handle, PHYSICALOFFSETY) * sy);
  p.Left := Round(GetDeviceCaps(Printer.Handle, PHYSICALOFFSETX) * sx);
  p.Width := Round(w * sx);
  p.Height := Round(h * sy);

  with PaintBox.Canvas do
  begin
  // la feuille à l'écran
    Pen.Color := clGray;
    Brush.Color := $f0f0f0;
    Rectangle(r);
  // la zone d'impressions
    Brush.Color := clWhite;
    FillRect(p);
  // limité le rendu du PDF à cette zone
    IntersectClipRect(Canvas.Handle, p.Left, P.Top, p.Right, p.Bottom);
  end;

  if FOptions.PageNumber <= Length(FOptions.Pages) then
  begin
    sx := FPrintScale * Screen.PixelsPerInch / 72;
    FPDFFrame.PrintPreview(PaintBox.Canvas, p, FOptions, sx, sx, False);
  end;
end;

procedure TPrintDlg.rbAllPagesClick(Sender: TObject);
begin
  edPages.Enabled := Sender = rbCustomPages;
  OnPageNumber();
  ComputePages();
  ResizePreview();
  PaintBox.Repaint;
end;

procedure TPrintDlg.rbAutoClick(Sender: TObject);
begin
  FOptions.Orientation := TRadioButton(Sender).Tag;
  ResizePreview();
  PaintBox.Repaint;
end;

procedure TPrintDlg.rbScaleClick(Sender: TObject);
var
  s1: Single;
begin
  FOptions.PageSize := TRadioButton(Sender).Tag;
  edCustomScale.Enabled := Sender = rbCustomScale;
  if Sender = rbCustomScale then
  begin
    if TryStrToFloat(edCustomScale.Text, s1) then
      FOptions.PageScale := s1 / 100
    else
      FOptions.PageScale := 1;
  end;
  ResizePreview();
  PaintBox.Repaint;
end;

procedure TPrintDlg.ResizePreview;
var
  s1, s2: Single;
  w, h, t: Integer;
begin
  ComputeScale();

  // taille du papier
  lbPageSize.Caption := Format('%2f x %2f cm', [FOptions.PaperWidth/100, FOptions.PaperHeight/100]);

  // Taille réelle
  if FOptions.PageSize = 1 then
    lbScale.Caption := Format('Document: %2f x %2f cm', [FPDFFrame.PageWidth(FOptions.CurrentPage) * 0.03528, FPDFFrame.PageHeight(FOptions.CurrentPage) * 0.03528])
  else
    lbScale.Caption := Format('Scale: %2f%%', [FOptions.PageScale * 100]);

  // Taille du papier en pixels à l'écran
  w := Round(FOptions.PaperWidth  / 100 / 2.54 * Screen.PixelsPerInch);
  h := Round(FOptions.PaperHeight / 100 / 2.54 * Screen.PixelsPerInch);

  // Rotation automatique
  if IsLandscape then
  begin
    t := h;
    h := w;
    w := t;
  end;

  // 290x380 est la taille "maxi" du PaintBox
  s1 := 290 / w;
  s2 := 380 / h;
  if s1 > s2 then
    s1 := s2;

  // Taille du papier à l'écran
  w := Round(s1 * w);
  h := Round(s1 * h);

  // Mise à l'échelle à l'écran
  FPrintScale := s1;

  // Dimension de la PaintBox
  PaintBox.SetBounds(
    15 + (290 - w) div 2,
    55 + (380 - h) div 2,
    w, h
  );

  // Position du label au dessus
  lbPageSize.Left := PaintBox.Left;
  lbPageSize.Top := PaintBox.Top - 25;
end;

end.
