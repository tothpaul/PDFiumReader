unit Execute.libPDFium;

{
   libPDFium.dll (c)2017-2020 by Execute SARL
   http://www.execute.fr
   https://github.com/tothpaul/PDFiumReader
}
{$WARN SYMBOL_PLATFORM OFF}


interface

uses
  Winapi.Windows,
  Winapi.ActiveX,
  System.Math;

const
  PDFIUM_VERSION = 2;

type
  // One point is 1/72 inch (around 0.3528 mm).
  TPointsSize = record
    cx : Double;
    cy : Double;
  end;

  TRectF = record
    Left, Top, Right, Bottom: Single;
  end;

  TRectD = record
    Left, Top, Right, Bottom: Double;
  end;

  IPDFAnnotation = interface
    function GetSubtype: Integer; stdcall;
    function GetRect(var Rect: TRectF): Integer; stdcall;
    function SetRect(const Rect: TRectF): Integer; stdcall;
    function GetString(const Key, Str: PChar; Size: Integer): Integer; stdcall;
    function Remove: Integer; stdcall;
  end;

  IPDFText = interface
    function CharCount: Integer; stdcall;
    function GetText(Start, Length: Integer; Text: PChar): Integer; stdcall;
    function CharIndexAtPos(const Pos: TPointsSize; distance: Integer): Integer; stdcall;
    function GetRectCount(Start, Length: Integer): Integer; stdcall;
    function GetRect(Index: Integer; var Rect: TRectD): Integer; stdcall;
  end;

  IPDFPage = interface
    function Render(DC: HDC; const Rect: TRect; Rotation, Flags: Integer): Integer; stdcall;
    function GetAnnotationCount: Integer; stdcall;
    function GetAnnotation(Index: Integer; var Annotation: IPDFAnnotation): Integer; stdcall;
    function GetText(var Text: IPDFText): Integer; stdcall;
    procedure DeviceToPage(const Rect: TRect; x, y: Integer; var px, py: Double); stdcall;
    procedure PageToDevice(const Rect: TRect; px, py: Double; var x, y: Integer); stdcall;
    function GetRotation: Integer; stdcall;
  end;

  TWriteProc = function(Data: Pointer; Size: Integer; UserData: Pointer): Integer; stdcall;

  IPDFium = interface
    function GetVersion: Integer; stdcall;
    function GetError: Integer; stdcall;
    function CloseDocument: integer; stdcall;
    function LoadFromFile(fileName, Password: PAnsiChar): Integer; stdcall;
    function LoadFromMemory(data: Pointer; Size: Integer; password: PAnsiChar): Integer; stdcall;
    function GetPermissions: LongWord; stdcall;
    function GetPageCount: Integer; stdcall;
    function GetPageSize(Index: Integer; var width, height: Double): Integer; stdcall;
    function GetPage(Index: Integer; out Page: IPDFPage): Integer; stdcall;
    function SaveToStream(Stream: IStream): Integer; stdcall;
    function SaveToProc(WriteProc: TWriteProc; UserData: Pointer): Integer; stdcall;
  end;

const
{$IFDEF WIN64}
  libpdfium = 'libpdfiumx64.dll';
{$ELSE}
  libpdfium = 'libpdfium.dll';
{$ENDIF}

  FPDF_ERR_SUCCESS  = 0;    // No error.
  FPDF_ERR_UNKNOWN  = 1;    // Unknown error.
  FPDF_ERR_FILE     = 2;    // File not found or could not be opened.
  FPDF_ERR_FORMAT   = 3;    // File not in PDF format or corrupted.
  FPDF_ERR_PASSWORD = 4;    // Password required or incorrect password.
  FPDF_ERR_SECURITY = 5;    // Unsupported security scheme.
  FPDF_ERR_PAGE     = 6;    // Page not found or content error.

  FPDF_ANNOT                    = $01;  // Set if annotations are to be rendered.
  FPDF_LCD_TEXT                 = $02;  // Set if using text rendering optimized for LCD display.
  FPDF_NO_NATIVETEXT            = $04;  // Don't use the native text output available on some platforms
  FPDF_GRAYSCALE                = $08;  // Grayscale output.
  FPDF_DEBUG_INFO               = $80;  // Set if you want to get some debug info.
  // Please discuss with Foxit first if you need to collect debug info.
  FPDF_NO_CATCH                 = $100; // Set if you don't want to catch exception.
  FPDF_RENDER_LIMITEDIMAGECACHE = $200; // Limit image cache size.
  FPDF_RENDER_FORCEHALFTONE     = $400; // Always use halftone for image stretching.
  FPDF_PRINTING                 = $800; // Render for printing.
  FPDF_REVERSE_BYTE_ORDER       = $10;  //set whether render in a reverse Byte order, this flag only

  FPDFANNOT_TEXTTYPE_Contents = 'Contents';
  FPDFANNOT_TEXTTYPE_Author = 'T';

  FPDF_ANNOT_UNKNOWN = 0;
  FPDF_ANNOT_TEXT = 1;
  FPDF_ANNOT_LINK = 2;
  FPDF_ANNOT_FREETEXT = 3;
  FPDF_ANNOT_LINE = 4;
  FPDF_ANNOT_SQUARE = 5;
  FPDF_ANNOT_CIRCLE = 6;
  FPDF_ANNOT_POLYGON = 7;
  FPDF_ANNOT_POLYLINE = 8;
  FPDF_ANNOT_HIGHLIGHT = 9;
  FPDF_ANNOT_UNDERLINE = 10;
  FPDF_ANNOT_SQUIGGLY = 11;
  FPDF_ANNOT_STRIKEOUT = 12;
  FPDF_ANNOT_STAMP = 13;
  FPDF_ANNOT_CARET = 14;
  FPDF_ANNOT_INK = 15;
  FPDF_ANNOT_POPUP = 16;
  FPDF_ANNOT_FILEATTACHMENT = 17;
  FPDF_ANNOT_SOUND = 18;
  FPDF_ANNOT_MOVIE = 19;
  FPDF_ANNOT_WIDGET = 20;
  FPDF_ANNOT_SCREEN = 21;
  FPDF_ANNOT_PRINTERMARK = 22;
  FPDF_ANNOT_TRAPNET = 23;
  FPDF_ANNOT_WATERMARK = 24;
  FPDF_ANNOT_THREED = 25;
  FPDF_ANNOT_RICHMEDIA = 26;
  FPDF_ANNOT_XFAWIDGET = 27;

function PDF_Create(RequestedVersion: Integer; out PDF: IPDFium): Integer; stdcall;
 external libpdfium delayed;

implementation

{$IFDEF WIN64}
initialization
  SetExceptionMask(exAllArithmeticExceptions);
{$ENDIF}
end.