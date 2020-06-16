unit DynamicButtons;

interface

uses
  System.Types,
  System.UITypes,
  Vcl.Graphics;

type
  TCanvasHelper = class helper for TCanvas
    procedure Folder(x: Integer);
    procedure Circle(x, y, w, h: Integer);
    procedure Minus(x: Integer);
    procedure Plus(x: Integer);
    procedure Paper(x, y, w, c: Integer);
    procedure Continus(x: Integer);
    procedure FixContinus(x: Integer);
    procedure FullPage(x: Integer);
    procedure FixFullPage(x: Integer);
    procedure ActualSize(x: Integer);
    procedure FixActualSize(x: Integer);
    procedure One(x, y: Integer);
    procedure About(x: Integer);
    procedure DrawButtons(x: Integer; Color: TColor);
    procedure FixButtons(x: Integer; Color: TColor);
    procedure Arrow(x, y: Integer);
    procedure Pipe(x: Integer);
    procedure Prev(x: Integer);
    procedure Next(x: Integer);
    procedure Print(x: Integer);
    procedure FixPrint(x: Integer);
  end;

procedure AntiAliaze(Bmp: TBitmap);

implementation


function Merge(c1, c2, c3, c4: Cardinal): Cardinal;
var
 r, g, b, a: Cardinal;
begin
  a := (c1 shr 24) and $ff + (c2 shr 24) and $ff + (c3 shr 24) and $ff + (c4 shr 24) and $ff;
  r := (c1 shr 16) and $ff + (c2 shr 16) and $ff + (c3 shr 16) and $ff + (c4 shr 16) and $ff;
  g := (c1 shr  8) and $ff + (c2 shr  8) and $ff + (c3 shr  8) and $ff + (c4 shr  8) and $ff;
  b := (c1       ) and $ff + (c2       ) and $ff + (c3       ) and $ff + (c4       ) and $ff;
  Result := (a shr 2) shl 24
          + (r shr 2) shl 16
          + (g shr 2) shl  8
          + (b shr 2);
end;

procedure AntiAliaze(Bmp: TBitmap);
type
  TPair = record
    c1, c2 : Cardinal;
  end;
var
  w,h:Integer;
  x,y: Integer;
  p1 : PCardinal;
  p2 : ^TPair;
  p3 : ^TPair;
begin
  w := Bmp.Width div 2;
  h := Bmp.Height div 2;
  for y := 0 to h - 1 do
  begin
    p1 := Bmp.ScanLine[y];
    p2 := Bmp.ScanLine[2 * y];
    p3 := Bmp.ScanLine[2 * y + 1];
    for x:= 0 to w - 1 do
    begin
      p1^ := Merge(p2.c1, p2.c2, p3.c1, p3.c2);
      Inc(p1);
      Inc(p2);
      Inc(p3);
    end;
  end;
  Bmp.SetSize(w, h);
end;

procedure TCanvasHelper.FixActualSize(x: Integer);
begin
  Pixels[x + 12, 14] := Pen.Color;
  Pixels[x + 12, 16] := Pen.Color;
end;

procedure TCanvasHelper.FixButtons(x: Integer; Color: TColor);
begin
  Pen.Color := Color;
  FixContinus(6 * 24 + x);
  FixFullPage(8 * 24 + x);
  FixActualSize(10 * 24 + x);
  FixPrint(18 * 24 + x);
end;

procedure TCanvasHelper.FixContinus(x: Integer);
var
  p: array[0..2] of TPoint;
begin
  Inc(x, 12);
  p[0].x :=  x - 5;
  p[0].y := 21;
  p[1].x :=  x - 3;
  p[1].y := 21 - 2;
  p[2].x :=  x - 3;
  p[2].y := 21 + 2;
  Polygon(p);
  p[0].x := x + 5;
  p[1].x := x + 3;
  p[2].x := x + 3;
  Polygon(p);
  MoveTo(x - 5, 21);
  LineTo(x + 5, 21);
end;

procedure TCanvasHelper.FixFullPage(x: Integer);
var
  p: array[0..2] of TPoint;
begin
  Brush.Color := Pen.Color;
  Inc(x, 12);
  p[0].x :=  x - 6;
  p[0].y := 12;
  p[1].x :=  x - 4;
  p[1].y := 12 - 2;
  p[2].x :=  x - 4;
  p[2].y := 12 + 2;
  Polygon(p);
  p[0].x := x + 6;
  p[1].x := x + 4;
  p[2].x := x + 4;
  Polygon(p);
  p[0].x :=  x;
  p[0].y :=  6;
  p[1].x :=  x - 2;
  p[1].y :=  8;
  p[2].x :=  x + 2;
  p[2].y :=  8;
  Polygon(p);
  p[0].y := 18;
  p[1].y := 16;
  p[2].y := 16;
  Polygon(p);
  MoveTo(x - 5, 12);
  LineTo(x - 1, 12);
  MoveTo(x + 2, 12);
  LineTo(x + 5, 12);
  MoveTo(x, 9);
  LineTo(x, 12);
  MoveTo(x, 13);
  LineTo(x, 16);
end;

procedure TCanvasHelper.FixPrint(x: Integer);
begin
  MoveTo(x +  7, 17);
  LineTo(x + 15, 17);
  MoveTo(x +  7, 19);
  LineTo(x + 15, 19);
end;

procedure TCanvasHelper.Folder(x: Integer);
var
  p: array[0..7] of TPoint;
  c: Cardinal;
  r: array [0..3] of Byte absolute c;
begin
  Brush.Color := $FAFAFA;
  p[0].x := x + 46; p[0].y := 20;
  p[1].x := x + 34; p[1].y := 42;
  p[2].x := x +  2; p[2].y := 42;
  p[3].x := x +  2; p[3].y :=  8;
  p[4].x := x + 18; p[4].y :=  8;
  p[5].x := x + 18; p[5].y := 14;
  p[6].x := x + 40; p[6].y := 14;
  p[7].x := x + 40; p[7].y := 20;
  Polygon(p);
  Brush.Color := $DEDEDE;
  p[3].x := x + 16; p[3].y := 20;
  Polygon(Slice(p, 4));
  Brush.Color := clWhite;
end;

procedure TCanvasHelper.About(x: Integer);
begin
  Circle(x +  3,  3, 42, 42);
  Font.Size := 20;
  Font.Color := Pen.Color;
  Font.Style := [fsBold];
  TextOut(x + 17, 7, '?');
end;

procedure TCanvasHelper.ActualSize(x: Integer);
begin
  Paper(x + 10, 4, 32, 10);
  One(x + 20, 22);
  One(x + 32, 22);
end;

procedure TCanvasHelper.One(x, y: Integer);
begin
  MoveTo(x - 2, y + 2);
  LineTo(x, y);
  LineTo(x, y + 14);
end;

procedure TCanvasHelper.Arrow(x, y: Integer);
var
  p: array[0..2] of TPoint;
begin
  p[0].x := x - 3;
  p[0].y := y;
  p[1].x := x + 3;
  p[1].y := y;
  p[2].x := x;
  p[2].y := y + 3;
  Polygon(p);
end;

procedure TCanvasHelper.Circle(x, y, w, h: Integer);
begin
  Ellipse(x, y, x + w, y + h);
end;

procedure TCanvasHelper.Continus(x: Integer);
begin
  Brush.Color := clWhite;
//  Rectangle(x + 10, -2, x + 41, 13);
  Paper(x + 10, -28, 30, 12);
  Paper(x + 10, +20, 30, 12);
end;

procedure TCanvasHelper.Minus(x: Integer);
begin
  Circle(x +  3,  3, 42, 42);
  Pixels[x + 23, 1] := clBtnFace;
  MoveTo(x + 14, 24);
  LineTo(x + 34, 24);
end;

procedure TCanvasHelper.Next(x: Integer);
begin
  Pipe(x);
  MoveTo(x + 24 - 8, 34 - 8);
  LineTo(x + 24, 34);
  LineTo(x + 24 + 8, 34 - 8);
end;

procedure TCanvasHelper.FullPage(x: Integer);
begin
  Paper(x + 10, 4, 32, 10);
end;

procedure TCanvasHelper.Paper(x, y, w, c: Integer);
var
  p: array[0..4] of TPoint;
begin
  p[0].X := x + w - c;
  p[0].Y := y;
  p[1].X := x + w;
  p[1].Y := y + c;
  p[2].X := x + w;
  p[2].Y := y + 40;
  p[3].X := x;
  p[3].Y := y + 40;
  p[4].X := x;
  p[4].Y := y;
  Polygon(p);
  p[2].X := x + w - c;
  p[2].Y := y + c;
  Polygon(Slice(p, 3));
end;

procedure TCanvasHelper.Pipe(x: Integer);
begin
  Circle(x +  3,  3, 42, 42);
  MoveTo(x + 24, 14);
  LineTo(x + 24, 34);
end;

procedure TCanvasHelper.Plus(x: Integer);
begin
  Minus(x);
  MoveTo(x + 24, 14);
  LineTo(x + 24, 34);
end;

procedure TCanvasHelper.Prev(x: Integer);
begin
  Pipe(x);
  MoveTo(x + 24 - 8, 14 + 8);
  LineTo(x + 24, 14);
  LineTo(x + 24 + 8, 14 + 8);
end;

procedure TCanvasHelper.Print(x: Integer);
begin
  Rectangle(x + 8,  6, x + 37, 47);
  Brush.Color := Pen.Color;
  Rectangle(x +  4, 20, x + 41, 30);
  Rectangle(x +  4, 18, x +  8, 35);
  Rectangle(x + 37, 18, x + 41, 35);
end;

procedure TCanvasHelper.DrawButtons(x: Integer; Color: TColor);
begin
  Pen.Color := Color;
  Folder(0 * 48 + x);
  Minus(2 * 48 + x);
  Plus(4 * 48 + x);
  Continus(6 * 48 + x);
  FullPage(8 * 48 + x);
  ActualSize(10 * 48 + x);
  About(12 * 48 + x);
  Prev(14 * 48 + x);
  Next(16 * 48 + x);
  Print(18 * 48 + x);
end;

end.
