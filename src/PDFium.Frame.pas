unit PDFium.Frame;

{
   PDF viewer using libPDFium.dll (c)2017-2018 by Execute SARL
   http://www.execute.fr
   https://github.com/tothpaul/PDFiumReader

   2017-09-09  v1.0
   2017-09-10  v1.1 better scrolling (less redraw)
   2018-11-30  v2.0 switched from PDFium.DLL to libPDFium.DLL

}

interface
{.$DEFINE TRACK_CURSOR}
{.$DEFINE TRACK_EVENTS}
uses
  Winapi.Windows, Winapi.Messages,

  System.SysUtils, System.Variants, System.Classes, System.Math,

  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,

  Execute.libPDFium, Vcl.ExtCtrls;

const
  PAGE_MARGIN = 5;  // pixels

type
  TPDFPrintOptions = record
    PageNumber: Integer; // Index dans Pages[]
    PageCount: Integer;
    Pages: TArray<Integer>;
    PageType: Integer; // 0 = Tout, 1 = Impaires, 2 = Paires
    PageSize: Integer; // 0 = Ajuster, 1 = Taille réelle, 2 = Auto, 3 = Echelle
    PageScale: Single; // Mise à l'échelle de la page
    Orientation: Integer; // 0 = Auto, 1 = Portrait, 2 = Paysage
    Rotation: Integer; // 1 si l'apperçu est horizontal (il faut faire une rotation à l'impression)
    PaperWidth: Integer; // 1/10 de mm
    PaperHeight: Integer; // 1/10 de mm
    GrayScale: Boolean;
    Center: Boolean;
    Annotations: Boolean;
    // Impression multipage
    PagePerSheet: Integer;
    PageOrder: Integer; // 0 = Horizontal, 1 = Horizontal inversé, 2 = Vertical, 3 = Vertical Inversé
    PageContour: Boolean;
    procedure AddPages(Start, Stop: Integer);
    function CurrentPage: Integer;
  end;

  TZoomMode = (
    zmCustom,
    zmActualSize,
    zmPageLevel,
    zmPageWidth
  );

  TPDFiumFrame = class(TFrame)
  private
    { Déclarations privées }
    type
      TPDFPage = class
        Index    : Integer;
        Handle     : IPDFPage;
        Top      : Double;
        Rect     : TRect;
        Text       : IPDFText;
        NoText   : Boolean;
        Visible  : Integer;
        SelStart : Integer;
        SelStop  : Integer;
        Selection: TArray<TRectD>;
        function HasText: Boolean;
        function CharIndex(x, y, distance: Integer): Integer;
        function CharCount: Integer;
        function Select(Start: Integer): Boolean;
        function SelectTo(Stop: Integer): Boolean;
        function ClearSelection: Boolean;
        procedure Paint(DC: HDC);
        procedure DrawSelection(DC, BMP: HDC; const Blend: TBlendFunction; const Client: TRect);
      end;

  private
    FPDF      : IPDFium;
    FError    : Integer;
    FPageCount: Integer;
    FPageSize : TArray<TPointsSize>;
    FTotalSize: TPointsSize;
    FPages    : TList;
    FReload   : Boolean;
    FPageIndex: Integer;
    FZoom     : Single;
    FZoomMode : TZoomMode;
    FStatus   : TLabel;
    FCurPage  : TPDFPage;
    FSelPage  : TPDFPage;
    FSelStart : Integer;
    FSelBmp   : TBitmap;
    FInvalide : Boolean;
    FOnPaint  : TNotifyEvent;
  {$IFDEF TRACK_CURSOR}
    FCharIndex: Integer;
    FCharBox  : TRectD;
  {$ENDIF}
    procedure OnLoad;
    procedure SetPageCount(Value: Integer);
    procedure SetScrollSize;
    procedure SetZoom(Value: Single);
    procedure SetZoomMode(Value: TZoomMode);
    procedure AdjustZoom;
    procedure ClearPages;
    function GetPage(PageIndex: Integer): TPDFPage;
    function GetPageAt(const p: TPoint): TPDFPage;
    procedure LoadVisiblePages;
    procedure WMEraseBkGnd(var Msg: TMessage); message WM_ERASEBKGND;
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  protected
    procedure PaintWindow(DC: HDC); override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    function GetPageTop(Index: Integer): Integer;
    function GetPageNumber: Integer;
    procedure SetPageNumber(Value: Integer);
    function GetPageY(PageIndex: Integer): Integer;
    function PageToScreen(Value: Single): Integer; inline;
    function ScaleToScreen: Single;
  public
    { Déclarations publiques }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    procedure CloseDocument();
    procedure LoadFromMemory(APointer: Pointer; ASize: Integer);
    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(const AFileName: string);
    procedure ClearSelection;
    function PageLevelZoom: Single;
    function PageWidthZoom: Single;
    procedure NextPage;
    procedure PrevPage;
    procedure GoPage(Index: Integer);
    procedure Print;
    procedure PrintPreview(Canvas: TCanvas; const ARect: TRect; const Options: TPDFPrintOptions; ScaleX, ScaleY: Single; Printer: Boolean);
    function PageWidth(PageNumber: Integer): Double;
    function PageHeight(PageNumber: Integer): Double;
    function IsLandscape(PageNumber: Integer): Boolean;
    function GetSelectionText: string;
    property PageIndex: Integer read FPageIndex;
    property PageCount: Integer read FPageCount;
    property PageNumber: Integer read GetPageNumber write SetPageNumber;
    property Zoom: Single read FZoom write SetZoom;
    property ZoomMode: TZoomMode read FZoomMode write SetZoomMode;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

implementation

{$R *.dfm}

uses PDFium.PrintDlg;

resourcestring
  sUnableToLoadPDFium = 'Unable to load libPDFium.dll';

procedure TPDFPrintOptions.AddPages(Start, Stop: Integer);
var
  Count: Integer;
  Len: Integer;
  Index: Integer;
begin
  if Stop > PageCount then
    Stop := PageCount;
  if Start < 0 then
    Start := 1;
  Count := Stop - Start + 1;
  if Count < 0 then
    Exit;
  Len := Length(Pages);
  SetLength(Pages, Len + Count);
  for Index := 0 to Count - 1 do
  begin
    if (PageType = 0) or ((PageType = 1) = Odd(Start)) then
    begin
      Pages[Len] := Start;
      Inc(Len);
    end;
    Inc(Start);
  end;
  SetLength(Pages, Len);
end;

function TPDFPrintOptions.CurrentPage: Integer;
begin
  if (PageNumber > 0) and (PageNumber <= Length(Pages)) then
    Result := Pages[PageNumber - 1]
  else
    Result := 0;
end;


{ TPDFiumFrame.TPDFPage }

function TPDFiumFrame.TPDFPage.HasText: Boolean;
begin
  if (Text = nil) and (NoText = False) then
  begin
    Handle.GetText(Text);
    NoText := Text = nil;
  end;
  Result := not NoText;
end;

procedure TPDFiumFrame.TPDFPage.Paint(DC: HDC);
var
  R: TRect;
  P: TPoint;
begin
  if (Rect.Left <> 0) or (Rect.Top <> 0) then
  begin
    R := TRect.Create(0, 0, Rect.Width, Rect.Height);
    SetViewportOrgEx(DC, Rect.Left, Rect.Top, @P);
    Handle.Render(DC, R, 0, FPDF_ANNOT);
    SetViewportOrgEx(DC, P.X, P.Y, nil);
  end else begin
    Handle.Render(DC, Rect, 0, FPDF_ANNOT);
  end;
end;

function TPDFiumFrame.TPDFPage.CharCount: Integer;
begin
  if HasText then
    Result := Text.CharCount
  else
    Result := 0;
end;

function TPDFiumFrame.TPDFPage.CharIndex(x, y, distance: Integer): Integer;
var
  Pos: TPointsSize;
begin
  if HasText = False then
    Exit(-1);
  Handle.DeviceToPage(Rect, x, y, Pos.cx, Pos.cy);
  Result := Text.CharIndexAtPos(Pos, distance);
end;

function TPDFiumFrame.TPDFPage.ClearSelection: Boolean;
begin
  Result := Selection <> nil;
  if Result then
  begin
    Selection := nil;
    SelStart := 0;
    SelStop := 0;
  end;
end;

procedure TPDFiumFrame.TPDFPage.DrawSelection(DC, BMP: HDC; const Blend: TBlendFunction; const Client: TRect);
var
  Index: Integer;
  R: TRect;
begin
  for Index := 0 to Length(Selection) - 1 do
  begin
    with Selection[Index] do
    begin
      Handle.PageToDevice(Rect, Left, Top, R.Left, R.Top);
      Handle.PageToDevice(Rect, Right, Bottom, R.Right, R.Bottom);
    end;
    if Client.IntersectsWith(R) then
      AlphaBlend(DC, R.Left, R.Top, R.Width, R.Height, BMP, 0, 0, 100, 50, Blend);
  end;
end;

function TPDFiumFrame.TPDFPage.Select(Start: Integer): Boolean;
begin
  Result := Selection <> nil;
  if (HasText = False) or (Start < 0) then
  begin
    Start := 0;
  end;
  SelStart := Start;
  SelStop := SelStart;
  Selection := nil;
end;

function TPDFiumFrame.TPDFPage.SelectTo(Stop: Integer): Boolean;
var
  SelLen: Integer;
  Start : Integer;
  Count : Integer;
  Index : Integer;
begin
  if Stop < 0 then
    Exit(False);

  if Stop > SelStart then
    Inc(Stop); // add one char

  if Stop = SelStop then
    Exit(False);
  Result := True;

  SelStop := Stop;
  SelLen := SelStop - SelStart;

  if SelLen = 0 then
    Selection := nil
  else begin
    if SelLen > 0 then
      Start := SelStart
    else begin
      Start := SelStop;
      SelLen := -SelLen;
    end;
    Count := Text.GetRectCount(Start, SelLen);
    SetLength(Selection, Count);
    for Index := 0 to Count - 1 do
    begin
      Text.GetRect(Index, Selection[Index]);
    end;
  end;

end;

{ TPDFiumFrame }

constructor TPDFiumFrame.Create(AOwner: TComponent);
begin
{$IFDEF TRACK_EVENTS}
  AllocConsole;
{$ENDIF}
  inherited;
  ControlStyle := ControlStyle + [csOpaque];
  FZoom := 100;
  FPageIndex := -1;

  FSelBmp := TBitmap.Create;
  FSelBmp.Canvas.Brush.Color := RGB(50, 142, 254);
  FSelBmp.SetSize(100, 50);

  FPages := TList.Create;
  try
    PDF_Create(PDFIUM_VERSION, FPDF);
  except
    FStatus := TLabel.Create(Self);
    FStatus.Align := alClient;
    FStatus.Parent := Self;
    FStatus.Alignment := taCenter;
    FStatus.Layout := tlCenter;
    FStatus.Caption := sUnableToLoadPDFium;
  end;
end;

destructor TPDFiumFrame.Destroy;
begin
  FPages.Free;
  inherited;
end;

function TPDFiumFrame.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  FReload := True;
  VertScrollBar.Position := VertScrollBar.Position - WheelDelta;
  Result := True;
end;

procedure TPDFiumFrame.LoadFromFile(const AFileName: string);
var
  AnsiName: AnsiString;
  Password: string;
  AnsiPwd : AnsiString;
begin
  AnsiName := AnsiString(AFileName);
  ClearPages;
  FError := FPDF.LoadFromFile(PAnsiChar(AnsiName), nil);
  while FError = FPDF_ERR_PASSWORD do
  begin
    if InputQuery('PDFium', 'Password', Password) = False then
      Break;
    AnsiPwd := AnsiString(Password);
    FError := FPDF.LoadFromFile(PAnsiChar(AnsiName), PAnsiChar(AnsiPwd));
  end;
  OnLoad;
end;

procedure TPDFiumFrame.LoadFromMemory(APointer: Pointer; ASize: Integer);
begin
  ClearPages;
  FError := FPDF.LoadFromMemory(APointer, ASize, nil);
  OnLoad;
end;

procedure TPDFiumFrame.LoadFromStream(AStream: TStream);
var
  Stream: TCustomMemoryStream;
begin
  if AStream is TCustomMemoryStream then
    Stream := TCustomMemoryStream(AStream)
  else begin
    Stream := TMemoryStream.Create;
    Stream.CopyFrom(AStream, AStream.Size - AStream.Position);
  end;
  try
    LoadFromMemory(Stream.Memory, Stream.Size);
  finally
    if Stream <> AStream then
      Stream.Free;
  end;
end;

procedure TPDFiumFrame.OnLoad;
begin
  if FError = 0 then
    SetPageCount(FPDF.GetPageCount)
  else
    SetPageCount(0);
  FReload := True;
  Invalidate;
end;

function TPDFiumFrame.ScaleToScreen: Single;
begin
  Result := FZoom / 100 * Screen.PixelsPerInch / 72;
end;

procedure TPDFiumFrame.SetPageCount(Value: Integer);
var
  Index: Integer;
begin
  FTotalSize.cx := 0;
  FTotalSize.cy := 0;
  FPageCount := Value;
  if FPageCount > 0 then
  begin
    SetLength(FPageSize, FPageCount);
    for Index := 0 to FPageCount - 1 do
      with FPageSize[Index] do
      begin
        FPDF.GetPageSize(Index, cx, cy);
        if cx > FTotalSize.cx then
          FTotalSize.cx := cx;
        FTotalSize.cy := FTotalSize.cy + cy;
      end;
  end;
  HorzScrollBar.Position := 0;
  VertScrollBar.Position := 0;
  SetScrollSize;
end;

procedure TPDFiumFrame.SetPageNumber(Value: Integer);
begin
  Dec(Value);
  if (Value >= 0) and (Value < FPageCount) and (FPageIndex <> Value) then
  begin
    FPageIndex := Value;
    FReload := True;
    VertScrollBar.Position := GetPageY(FPageIndex);
  end;
end;

procedure TPDFiumFrame.SetScrollSize;
var
  Scale: Single;
begin
  Scale := FZoom / 100 * Screen.PixelsPerInch / 72;
  HorzScrollBar.Range := Round(FTotalSize.cx * Scale) + PAGE_MARGIN * 2;
  VertScrollBar.Range := Round(FTotalSize.cy * Scale) + PAGE_MARGIN * (FPageCount + 1);
end;

procedure TPDFiumFrame.SetZoom(Value: Single);
begin
  if Value < 0.65 then
    Value := 0.65;
  if Value > 6400 then
    Value := 6400;
  FZoom := Value;
  SetScrollSize;
  FReload := True;
  Invalidate;
  if Assigned(OnResize) then
    OnResize(Self);
end;

procedure TPDFiumFrame.SetZoomMode(Value: TZoomMode);
begin
  FZoomMode := Value;
  AdjustZoom;
end;

procedure TPDFiumFrame.AdjustZoom;
begin
  case FZoomMode of
    zmCustom    : Exit;
    zmActualSize: Zoom := 100;
    zmPageLevel : Zoom := PageLevelZoom;
    zmPageWidth : Zoom := PageWidthZoom;
  end;
end;

procedure TPDFiumFrame.ClearPages;
var
  Index: Integer;
begin
  FCurPage := nil;
  for Index := 0 to FPages.Count - 1 do
    TPDFPage(FPages[Index]).Free;
  FPages.Clear;
end;

procedure TPDFiumFrame.ClearSelection;
var
  Clear: Boolean;
  Index: Integer;
  Page : TPDFPage;
begin
  Clear := False;
  for Index := 0 to FPages.Count - 1 do
  begin
    Page := FPages[Index];
    if Page.ClearSelection then
      Clear := True;
  end;
  if Clear then
    Invalidate;
end;

procedure TPDFiumFrame.CloseDocument;
begin
  ClearPages;
  FPDF.CloseDocument;
  SetPageCount(0);
  Invalidate;
end;

function TPDFiumFrame.GetPage(PageIndex: Integer): TPDFPage;
var
  Index: Integer;
begin
  for Index := 0 to FPages.Count - 1 do
  begin
    Result := FPages[Index];
    if Result.Index = PageIndex then
      Exit;
  end;
  Result := TPDFPage.Create;
  FPages.Add(Result);
  Result.Index := PageIndex;
  FPDF.GetPage(PageIndex, Result.Handle);
end;

function TPDFiumFrame.GetPageAt(const p: TPoint): TPDFPage;
var
  Index: Integer;
begin
  for Index := 0 to FPages.Count - 1 do
  begin
    Result := FPages[Index];
    if (Result.Visible > 0) and (Result.Rect.Contains(p)) then
      Exit;
  end;
  Result := nil;
end;

function TPDFiumFrame.GetPageNumber: Integer;
begin
  Result := FPageIndex + 1;
end;

function TPDFiumFrame.GetPageTop(Index: Integer): Integer;
var
  PageTop: Single;
begin
  PageTop := 0;
  Result := PAGE_MARGIN * Index;
  while Index > 0 do
  begin
    Dec(Index);
    PageTop := PageTop + FPageSize[Index].cy;
  end;
  Inc(Result, Round(PageTop * FZoom / 100 * Screen.PixelsPerInch / 72));
end;

function TPDFiumFrame.GetPageY(PageIndex: Integer): Integer;
var
  y: Double;
begin
  Result := PageIndex * PAGE_MARGIN;
  y := 0;
  while PageIndex > 0 do
  begin
    Dec(PageIndex);
    y := y + FPageSize[PageIndex].cy;
  end;
  Inc(Result, PageToScreen(y));
end;


function TPDFiumFrame.GetSelectionText: string;
var
  Index: Integer;
  Page: TPDFPage;
  Count: Integer;
  SelLen: Integer;
begin
  Count := 0;
  Result := '';
  for Index := 0 to Pred(FPDF.GetPageCount) do
  begin
    Page := GetPage(Index);
    SelLen := Page.SelStop - Page.SelStart;
    if SelLen = 0 then
      Continue;
    SetLength(Result, Count + Abs(SelLen));
    if SelLen < 0 then
      Page.Text.GetText(Page.SelStop, - SelLen, @Result[Count + 1])
    else
      Page.Text.GetText(Page.SelStart, SelLen, @Result[Count + 1]);
    Inc(Count, Abs(SelLen));
  end;
end;

procedure TPDFiumFrame.GoPage(Index: Integer);
begin
  if (Index >= 0) and (Index < PageCount) then
  begin
    FReload := True;
    VertScrollBar.Position := GetPageTop(Index);
  end;
end;

procedure TPDFiumFrame.Invalidate;
begin
  if FInvalide = False then
  begin
    inherited;
    FInvalide := True;
  end else begin
  {$IFDEF TRACK_EVENTS}WriteLn('Not invalidated');{$ENDIF}
  end;
end;

function TPDFiumFrame.IsLandscape(PageNumber: Integer): Boolean;
begin
  Result := (PageNumber > 0) and (PageNumber <= Length(FPageSize))
    and (FPageSize[PageNumber - 1].cx > FPageSize[PageNumber - 1].cy);
end;

procedure TPDFiumFrame.LoadVisiblePages;
var
  Index : Integer;
  Page  : TPDFPage;
  Top   : Double;
  Scale : Double;
  Client: TRect;
  Rect  : TRect;
  Marge : Integer;
begin
  FPageIndex := -1;
  FCurPage := nil;

  for Index := 0 to FPages.Count - 1 do
  begin
    Page := FPages[Index];
    if Page.Selection = nil then
      Dec(Page.Visible)
    else
      Page.Visible := 0;
  end;

  Client := ClientRect;
  Top := 0;
  Marge := PAGE_MARGIN;
  Scale := FZoom / 100 * Screen.PixelsPerInch / 72;
  for Index := 0 to FPageCount - 1 do
  begin
  // compute page position
    Rect.Top := Round(Top * Scale) + Marge - VertScrollBar.Position;
    Rect.Left := PAGE_MARGIN + Round((FTotalSize.cx - FPageSize[Index].cx) / 2 * Scale) - HorzScrollBar.Position;
    Rect.Width := Round(FPageSize[Index].cx * Scale);
    Rect.Height := Round(FPageSize[Index].cy * Scale);
    if Rect.Width < Client.Width - 2 * PAGE_MARGIN then
      Rect.Offset((Client.Width - Rect.Width) div 2 - Rect.Left, 0);
  // visibility test
    if Rect.IntersectsWith(Client) then
    begin
      if FPageIndex < 0 then
        FPageIndex := Index;
      Page := GetPage(Index);
      Page.Rect := Rect;
      Page.Visible := 1;
    end;
  // don't go below client area
    if Rect.Top > Client.Bottom then
      Break;
  // next page top position
    Top := Top + FPageSize[Index].cy;
    Inc(Marge, PAGE_MARGIN);
  end;

  // release any page that was not visibile for the last 5 paint events
  for Index := FPages.Count - 1 downto 0 do
  begin
    Page := FPages[Index];
    if Page.Visible < -5 then
    begin
      Page.Free;
      FPages.Delete(Index);
    end;
  end;
end;


procedure TPDFiumFrame.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  i: Integer;
begin
  inherited;
  SetFocus();
  if FCurPage <> nil then
  begin
    ClearSelection;
    i := FCurPage.CharIndex(x, y, 5);
    if i >= 0 then
    begin
      FSelPage := FCurPage; // selection mode
      FSelStart := FSelPage.Index; // page index where the selections start
      FSelPage.Select(i); // set SelStart
    end;
  end;
end;

procedure TPDFiumFrame.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  i: Integer;
begin
  inherited;

  p.x := x;
  p.y := y;

  // page under the cursor
  if (FCurPage = nil) or (FCurPage.Rect.Contains(p) = False) then
  begin
    FCurPage := GetPageAt(p);
  end;

  // there's a page under the cursor
  if FCurPage = nil then
    i := -1
  else begin
    if FCurPage = FSelPage then // in selection mode, allows more flexible search
      i := 65535
    else
      i := 5;
    i := FCurPage.CharIndex(x, y, i); // character under the cursor in the current page
  end;

{$IFDEF TRACK_CURSOR}
  if i <> FCharIndex then
  begin
    FCharIndex := i;
    if FCharIndex >= 0 then
      FPDFText_GetCharBox(FCurPage.Text, i, FCharBox.Left, FCharBox.Right, FCharBox.Bottom, FCharBox.Top);
    Invalidate;
  end;
{$ENDIF}

  // selecting
  if FSelPage <> nil then
  begin
    // move the mouse inside the same page
    if FSelPage = FCurPage then
    begin
      if FSelPage.SelectTo(i) then // selStop
        Invalidate;
      Exit; // done
    end;
    // the mouse is outside the page
    if y < FSelPage.Rect.Top then // above
    begin
      if FSelPage.Index > FSelStart then // remove selection
        FSelPage.ClearSelection
      else
        FSelPage.SelectTo(0) // or extend it to the top of the page
    end else begin  // below
      if FSelPage.Index < FSelStart then // remove selection
        FSelPage.ClearSelection
      else
        FSelPage.SelectTo(FSelPage.CharCount); // extend to the bottom of the page
    end;
    Invalidate;
    // mouse over an other page with a character found
    if (FCurPage <> nil) and (i >= 0) then
    begin
      FSelPage := FCurPage; // change selected page
      if FSelPage.Selection = nil then // new page
      begin
        if FSelPage.Index > FSelStart then // from the top ...
          FSelPage.Select(0)
        else
          FSelPage.Select(FSelPAge.CharCount) // or from the bottom ...
        end;
      FSelPage.SelectTo(i); // ... to the active character
    end;
    Exit;
  end;

  // no selection, change cursor as needed
  if i = -1 then
  begin
    Cursor := crDefault;
  end else begin
    Cursor := crIBeam;
  end;
end;

procedure TPDFiumFrame.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  FSelPage := nil; // exit selection mode
end;

procedure TPDFiumFrame.NextPage;
begin
  GoPage(FPageIndex + 1);
end;

procedure TPDFiumFrame.WMEraseBkGnd(var Msg: TMessage);
begin
{$IFDEF TRACK_EVENTS}WriteLn('WM_ERASEBKGND');{$ENDIF}
  Msg.Result := 1;
end;

procedure TPDFiumFrame.WMHScroll(var Message: TWMHScroll);
begin
{$IFDEF TRACK_EVENTS}WriteLn('WM_HSCROLL');{$ENDIF}
  FReload := True;
  inherited;
end;

procedure TPDFiumFrame.WMVScroll(var Message: TWMVScroll);
begin
{$IFDEF TRACK_EVENTS}WriteLn('WM_VSCROLL');{$ENDIF}
  FReload := True;
  inherited;
end;
{$IFDEF TRACK_EVENTS}
var
  Paints: Integer = 0;
{$ENDIF}
procedure TPDFiumFrame.WMPaint(var Msg: TWMPaint);
begin
{$IFDEF TRACK_EVENTS}WriteLn('WM_PAINT ', Paints); Inc(Paints);{$ENDIF}
  ControlState := ControlState + [csCustomPaint];
  inherited;
  ControlState := ControlState - [csCustomPaint];
end;

function TPDFiumFrame.PageHeight(PageNumber: Integer): Double;
begin
  if (PageNumber > 0) and (PageNumber <= Length(FPageSize)) then
    Result := FPageSize[PageNumber - 1].cy
  else
    Result := 1;
end;

function TPDFiumFrame.PageLevelZoom: Single;
var
  Scale : Single;
  Z1, Z2: Single;
begin
  if FPageIndex < 0 then
    Exit(100);
  Scale := 72 / Screen.PixelsPerInch;
  Z1 := (ClientWidth  - 2 * PAGE_MARGIN) * Scale / FPageSize[FPageIndex].cx;
  Z2 := (ClientHeight - 2 * PAGE_MARGIN) * Scale / FPageSize[FPageIndex].cy;
  if Z1 > Z2 then
    Z1 := Z2;
  Result := 100 * Z1;
end;

function TPDFiumFrame.PageToScreen(Value: Single): Integer;
begin
  Result := Round(Value * ScaleToScreen);
end;

function TPDFiumFrame.PageWidth(PageNumber: Integer): Double;
begin
  if (PageNumber > 0) and (PageNumber <= Length(FPageSize)) then
    Result := FPageSize[PageNumber - 1].cx
  else
    Result := 1;
end;

function TPDFiumFrame.PageWidthZoom: Single;
var
  Scale : Single;
begin
  if FPageIndex < 0 then
    Exit(100);
  Scale := 72 / Screen.PixelsPerInch;
  Result := 100 * (ClientWidth  - 2 * PAGE_MARGIN) * Scale / FPageSize[FPageIndex].cx;
end;

procedure TPDFiumFrame.PaintWindow(DC: HDC);
var
  Index : Integer;
  Page  : TPDFPage;
  Client: TRect;
  WHITE : HBrush;
  SelDC : HDC;
  Blend : TBlendFunction;
begin
  FInvalide := False;
// Target rect
  Client := ClientRect;
// gray background
  FillRect(DC, Client, GetStockObject(GRAY_BRUSH));
// nothing to render
  if FPageCount = 0 then
    Exit;
// check visibility
  if FReload or (FPages.Count = 0) then
  begin
    LoadVisiblePages;
    FReload := False;
  end;
// page background
  WHITE := GetStockObject(WHITE_BRUSH);

  SelDC := FSelBMP.Canvas.Handle;

  Blend.BlendOp := AC_SRC_OVER;
  Blend.BlendFlags := 0;
  Blend.SourceConstantAlpha := 127;
  Blend.AlphaFormat := 0;

  for Index := 0 to FPages.Count - 1 do
  begin
    Page := FPages[Index];
    if Page.Visible > 0 then
    begin
      FillRect(DC, Page.Rect, WHITE);
//      Page.Handle.Render(DC, Page.Rect, 0, FPDF_ANNOT);
      Page.Paint(DC);
      Page.DrawSelection(DC, SelDC, Blend, Client);
    end;
  end;
{$IFDEF TRACK_CURSOR}
  if (FCurPage <> nil) and (FCharIndex >= 0) then
  begin
    with FCurPage do
    begin
      FPDF_PageToDevice(Handle, Rect.Left, Rect.Top, Rect.Width, Rect.Height, 0, FCharBox.Left, FCharBox.Top, Client.Left, Client.Top);
      FPDF_PageToDevice(Handle, Rect.Left, Rect.Top, Rect.Width, Rect.Height, 0, FCharBox.Right, FCharBox.Bottom, Client.Right, Client.Bottom);
    end;
    DrawFocusRect(DC, Client);
  end;
{$ENDIF}
  if Assigned(FOnPaint) then
    FOnPaint(Self);
end;

procedure TPDFiumFrame.PrevPage;
begin
  GoPage(FPageIndex - 1);
end;

procedure TPDFiumFrame.Print;
begin
  TPrintDlg.Execute(Self);
end;

procedure TPDFiumFrame.PrintPreview(Canvas: TCanvas; const ARect: TRect;
  const Options: TPDFPrintOptions; ScaleX, ScaleY: Single; Printer: Boolean);
var
  n, p: Integer;
  pn: Integer;
  pr, pc: Integer;
  nPage: Integer;
  iPage: IPDFPage;
  Rect: TRect;
  R, c: Integer;
  Flags: Integer;
  w, h: Integer;
  s1, s2: Single;
  wf, hf: Single;
  Rotation: Integer;
  Save: Integer;
  R2: TRect;
begin
  if Length(Options.Pages) = 0 then
    Exit;

  p := Options.PageNumber - 1;

  case Options.PagePerSheet of
    1:
      c := 1;
    2:
      c := 2;
    4:
      c := 2;
    6:
      c := 3;
    9:
      c := 3;
  else//  16:
      c := 4;
  end;
  R := Options.PagePerSheet div c;

  // faire la découpe dans le sens de la longeur
  if ((c > R) and (ARect.Width < ARect.Height)) or ((R > c) and (ARect.Height < ARect.Width)) then
  begin
    w := c;
    c := R;
    R := w;
  end;

  // imprimer toutes les pages
  for n := 0 to Options.PagePerSheet - 1 do
  begin
    // la page à imprimer
    if Options.PagePerSheet > 1 then
    begin
      pr := n div c;
      pc := n - c * pr;
      if Options.Rotation = 1 then
      begin
        case Options.PageOrder of
          0:
            pn := Options.PageNumber - 1 + (c - pc - 1) * (c + 1) + pr; // Horizontal
          1:
            pn := Options.PageNumber - 1 + (c - pc - 1) * R + R - pr - 1; // Horizontal inversé
          2:
            pn := Options.PageNumber - 1 + pr * c + c - pc - 1; // Vertical
        else//  3:
            pn := Options.PageNumber - 1 + pr * c + pc; // Vertical inversé
        end;
      end
      else
      begin
        case Options.PageOrder of
          0:
            pn := p; // Horizontal
          1:
            pn := Options.PageNumber - 1 + pr * c + c - pc - 1; // Horizontal inversé
          2:
            pn := Options.PageNumber - 1 + pc * R + pr; // Vertical
        else//  3:
            pn := Options.PageNumber - 1 + pc * R + R - pr - 1; // Vertical inversé
        end;
      end;
    end
    else
    begin
      pn := p;
    end;

    if pn >= Length(Options.Pages) then
      Continue;

    nPage := Options.Pages[pn] - 1;
    if (nPage < 0) or (nPage >= Length(FPageSize)) then
      Continue;
    FPDF.GetPage(nPage, iPage);

    Inc(p);

    // on part du rectangle donné
    Rect := ARect;
    // réduire les dimensions en fonction du nombre de lignes/colonnes
    Rect.Width := Rect.Width div c;
    Rect.Height := Rect.Height div R;
    // déplacer le rectangle sur la page
    Rect.Offset(Rect.Width * (n mod c), Rect.Height * (n div c));

    // Dimensions de la page à l'écran
    Rotation := 0;
    wf := FPageSize[nPage].cx;
    hf := FPageSize[nPage].cy;

    if (((Options.Orientation = 2) and (Rect.Width < Rect.Height)) or ((Options.Orientation = 0) and ((wf > hf) <> (Rect.Width > Rect.Height)))) then
    begin
      wf := hf;
      hf := FPageSize[nPage].cx;
      Rotation := iPage.GetRotation;
      if Rotation = 0 then
        Rotation := 1 // +90°
      else
        Rotation := 3; // -90°
    end;

    // ne se produit qu'à l'impression, à l'écran c'est l'image qui est tournée
    if (Options.Rotation = 1) and (Options.Orientation = 1) then
    begin
      s1 := hf;
      hf := wf;
      wf := s1;
      if Rotation = 0 then
        Rotation := 1 // +90°
      else
        Rotation := 0;
    end;

    if Options.PageSize in [0, 2] then
    begin
      s1 := Rect.Width / (ScaleX * wf * Options.PageScale);
      s2 := Rect.Height / (ScaleY * hf * Options.PageScale);
      if s2 < s1 then
        s1 := s2;
      if (Options.PageSize = 2) and (s1 > 1) then
        s1 := 1;
      ScaleX := ScaleX * s1;
      ScaleY := ScaleY * s1;
    end;
    w := Round(ScaleX * wf * Options.PageScale);
    h := Round(ScaleY * hf * Options.PageScale);

    // Center l'impression dans la zone d'impression
    if Options.Center then
    begin
      Inc(Rect.Left, (Rect.Width - w) div 2);
      Inc(Rect.Top, (Rect.Height - h) div 2);
    end;
    Rect.Width := w;
    Rect.Height := h;

    // bord de la page
    if Options.PageContour or (not Printer) then
    begin
      Rect.Inflate(1, 1);
      if Options.PageContour then
      begin
        Canvas.Pen.Color := clBlack;
      end
      else
      begin
        Canvas.Pen.Color := clSilver;
        Canvas.Pen.Style := psDot;
      end;
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(Rect);
      Canvas.Pen.Style := psSolid;
      Rect.Inflate(-1, -1);
    end;

    Flags := 0;
    if Options.GrayScale then
      Flags := Flags or FPDF_GRAYSCALE;
    if Options.Annotations then
      Flags := Flags or FPDF_ANNOT;

    Save := SaveDC(Canvas.Handle);
    // bug in PDFium
    R2 := TRect.Create(0, 0, Rect.Width, Rect.Height);
    SetViewportOrgEx(Canvas.Handle, Rect.Left, Rect.Top, nil);
    iPage.Render(Canvas.Handle, R2, Rotation, Flags);
    RestoreDC(Canvas.Handle, Save);

  end;
end;

procedure TPDFiumFrame.Resize;
begin
  inherited;
  AdjustZoom;
  FReload := True;
// repaing
  Invalidate;
end;

end.
