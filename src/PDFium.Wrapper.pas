unit PDFium.Wrapper;
{
   PDF viewer using PDFium.dll (c)2017 by Execute SARL
   http://www.execute.fr
   https://github.com/tothpaul/Delphi

   inspired by PdfiumLib
   https://github.com/ahausladen/PdfiumLib

}
interface

{$DEFINE DELAYED}
{$IFDEF DELAYED}
  {$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}
const
  DLL = 'PDFium.dll';

type
  HPDFDocument = type THandle;
  HPDFPage     = type THandle;
  HPDFTextPage = type THandle;

// Function: FPDF_InitLibrary
//      Initialize the FPDFSDK library
// Parameters:
//      None
// Return value:
//      None.
// Comments:
//      You have to call this function before you can call any PDF processing functions.
procedure FPDF_InitLibrary;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_InitLibrary@0'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

const
  FPDF_ERR_SUCCESS  = 0;    // No error.
  FPDF_ERR_UNKNOWN  = 1;    // Unknown error.
  FPDF_ERR_FILE     = 2;    // File not found or could not be opened.
  FPDF_ERR_FORMAT   = 3;    // File not in PDF format or corrupted.
  FPDF_ERR_PASSWORD = 4;    // Password required or incorrect password.
  FPDF_ERR_SECURITY = 5;    // Unsupported security scheme.
  FPDF_ERR_PAGE     = 6;    // Page not found or content error.

// Function: FPDF_GetLastError
//      Get last error code when an SDK function failed.
// Parameters:
//      None.
// Return value:
//      A 32-bit integer indicating error codes (defined above).
// Comments:
//      If the previous SDK call succeeded, the return value of this function
//      is not defined.
//
function FPDF_GetLastError: Integer;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_GetLastError@0'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDF_LoadMemDocument
//      Open and load a PDF document from memory.
// Parameters:
//      data_buf  -  Pointer to a buffer containing the PDF document.
//      size      -  Number of bytes in the PDF document.
//      password  -  A string used as the password for PDF file.
//                    If no password needed, empty or NULL can be used.
// Return value:
//      A handle to the loaded document. If failed, NULL is returned.
// Comments:
//      The memory buffer must remain valid when the document is open.
//      Loaded document can be closed by FPDF_CloseDocument.
//      If this function fails, you can use FPDF_GetLastError() to retrieve
//      the reason why it fails.
//
function FPDF_LoadMemDocument(data_buf: Pointer; size: Integer; password: PAnsiChar): HPDFDocument;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_LoadMemDocument@12'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDF_LoadDocument
//      Open and load a PDF document.
// Parameters:
//      file_path  -  Path to the PDF file (including extension).
//      password   -  A string used as the password for PDF file.
//                     If no password needed, empty or NULL can be used.
// Return value:
//      A handle to the loaded document. If failed, NULL is returned.
// Comments:
//      Loaded document can be closed by FPDF_CloseDocument.
//      If this function fails, you can use FPDF_GetLastError() to retrieve
//      the reason why it fails.
//
function FPDF_LoadDocument(file_path, password: PAnsiChar): HPDFDocument;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_LoadDocument@8'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};


// Function: FPDF_CloseDocument
//      Close a loaded PDF document.
// Parameters:
//      document  -  Handle to the loaded document.
// Return value:
//      None.
//
procedure FPDF_CloseDocument(document: HPDFDocument);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_CloseDocument@4'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDF_GetPageCount
//      Get total number of pages in a document.
// Parameters:
//      document  -  Handle to document. Returned by FPDF_LoadDocument function.
// Return value:
//      Total number of pages in the document.
//
function FPDF_GetPageCount(document: HPDFDocument): Integer;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_GetPageCount@4'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDF_GetPageSizeByIndex
//      Get the size of a page by index.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument function.
//      page_index  -  Page index, zero for the first page.
//      width       -  Pointer to a double value receiving the page width (in points).
//      height      -  Pointer to a double value receiving the page height (in points).
// Return value:
//      Non-zero for success. 0 for error (document or page not found).
//
function FPDF_GetPageSizeByIndex(document: HPDFDocument; page_index: Integer; var width, height: Double): Integer;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_GetPageSizeByIndex@16'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDF_LoadPage
//      Load a page inside a document.
// Parameters:
//      document    -  Handle to document. Returned by FPDF_LoadDocument function.
//      page_index  -  Index number of the page. 0 for the first page.
// Return value:
//      A handle to the loaded page. If failed, NULL is returned.
// Comments:
//      Loaded page can be rendered to devices using FPDF_RenderPage function.
//      Loaded page can be closed by FPDF_ClosePage.
//
function FPDF_LoadPage(document: HPDFDocument; page_index: Integer): HPDFPage;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_LoadPage@8'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

{$IFDEF MSWINDOWS}
// Page rendering flags. They can be combined with bit OR.
const
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
                                        //enable when render to a bitmap.
// Function: FPDF_RenderPage
//      Render contents in a page to a device (screen, bitmap, or printer).
//      This function is only supported on Windows system.
// Parameters:
//      dc      -  Handle to device context.
//      page    -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x -  Left pixel position of the display area in the device coordinate.
//      start_y -  Top pixel position of the display area in the device coordinate.
//      size_x  -  Horizontal size (in pixels) for displaying the page.
//      size_y  -  Vertical size (in pixels) for displaying the page.
//      rotate  -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                 2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      flags   -  0 for normal display, or combination of flags defined above.
// Return value:
//      None.
//
procedure FPDF_RenderPage(DC: THandle; page: HPDFPage; start_x, start_y, size_x, size_y, rotate, flags: Integer);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_RenderPage@32'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};
{$ENDIF}

// Function: FPDF_DeviceToPage
//      Convert the screen coordinate of a point to page coordinate.
// Parameters:
//      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x   -  Left pixel position of the display area in the device coordinate.
//      start_y   -  Top pixel position of the display area in the device coordinate.
//      size_x    -  Horizontal size (in pixels) for displaying the page.
//      size_y    -  Vertical size (in pixels) for displaying the page.
//      rotate    -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                   2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      device_x  -  X value in device coordinate, for the point to be converted.
//      device_y  -  Y value in device coordinate, for the point to be converted.
//      page_x    -  A Pointer to a double receiving the converted X value in page coordinate.
//      page_y    -  A Pointer to a double receiving the converted Y value in page coordinate.
// Return value:
//      None.
// Comments:
//      The page coordinate system has its origin at left-bottom corner of the page, with X axis goes along
//      the bottom side to the right, and Y axis goes along the left side upward. NOTE: this coordinate system
//      can be altered when you zoom, scroll, or rotate a page, however, a point on the page should always have
//      the same coordinate values in the page coordinate system.
//
//      The device coordinate system is device dependent. For screen device, its origin is at left-top
//      corner of the window. However this origin can be altered by Windows coordinate transformation
//      utilities. You must make sure the start_x, start_y, size_x, size_y and rotate parameters have exactly
//      same values as you used in FPDF_RenderPage() function call.
//
procedure FPDF_DeviceToPage(page: HPDFPage; start_x, start_y, size_x, size_y,
    rotate, device_x, device_y: Integer; var page_x, page_y: Double);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_DeviceToPage@40'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDF_PageToDevice
//      Convert the page coordinate of a point to screen coordinate.
// Parameters:
//      page      -  Handle to the page. Returned by FPDF_LoadPage function.
//      start_x   -  Left pixel position of the display area in the device coordinate.
//      start_y   -  Top pixel position of the display area in the device coordinate.
//      size_x    -  Horizontal size (in pixels) for displaying the page.
//      size_y    -  Vertical size (in pixels) for displaying the page.
//      rotate    -  Page orientation: 0 (normal), 1 (rotated 90 degrees clockwise),
//                   2 (rotated 180 degrees), 3 (rotated 90 degrees counter-clockwise).
//      page_x    -  X value in page coordinate, for the point to be converted.
//      page_y    -  Y value in page coordinate, for the point to be converted.
//      device_x  -  A pointer to an integer receiving the result X value in device coordinate.
//      device_y  -  A pointer to an integer receiving the result Y value in device coordinate.
// Return value:
//      None.
// Comments:
//      See comments of FPDF_DeviceToPage() function.
//
procedure FPDF_PageToDevice(page: HPDFPage; start_x, start_y, size_x, size_y,
    rotate: Integer; page_x, page_y: Double; var device_x, device_y: Integer);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_PageToDevice@48'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDF_ClosePage
//      Close a loaded PDF page.
// Parameters:
//      page    -  Handle to the loaded page.
// Return value:
//      None.
//
procedure FPDF_ClosePage(page: HPDFPage);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDF_ClosePage@4'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDFText_LoadPage
//      Prepare information about all characters in a page.
// Parameters:
//      page  -  Handle to the page. Returned by FPDF_LoadPage function (in FPDFVIEW module).
// Return value:
//      A handle to the text page information structure.
//      NULL if something goes wrong.
// Comments:
//      Application must call FPDFText_ClosePage to release the text page information.
//      If you don't purchase Text Module , this function will return NULL.
//
function FPDFText_LoadPage(page: HPDFPage): HPDFTextPage;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDFText_LoadPage@4'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};


// Function: FPDFText_CountChars
//      Get number of characters in a page.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return value:
//      Number of characters in the page. Return -1 for error.
//      Generated characters, like additional space characters, new line characters, are also counted.
// Comments:
//      Characters in a page form a "stream", inside the stream, each character has an index.
//      We will use the index parameters in many of FPDFTEXT functions. The first character in the page
//      has an index value of zero.
//
function FPDFText_CountChars(text_page: HPDFPage): Integer;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDFText_CountChars@4'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDFText_GetCharIndexAtPos
//      Get the index of a character at or nearby a certain position on the page.
// Parameters:
//      text_page   -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      x           -  X position in PDF "user space".
//      y           -  Y position in PDF "user space".
//      xTolerance  -  An x-axis tolerance value for character hit detection, in point unit.
//      yTolerance  -  A y-axis tolerance value for character hit detection, in point unit.
// Return Value:
//      The zero-based index of the character at, or nearby the point (x,y).
//      If there is no character at or nearby the point, return value will be -1.
//      If an error occurs, -3 will be returned.
//
function FPDFText_GetCharIndexAtPos(text_page: HPDFTextPage; x, y, xTorelance, yTolerance: Double): Integer;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDFText_GetCharIndexAtPos@36'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDFText_GetCharBox
//      Get bounding box of a particular character.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      index      -  Zero-based index of the character.
//      left       -  Pointer to a double number receiving left position of the character box.
//      right      -  Pointer to a double number receiving right position of the character box.
//      bottom     -  Pointer to a double number receiving bottom position of the character box.
//      top        -  Pointer to a double number receiving top position of the character box.
// Return Value:
//      None.
// Comments:
//      All positions are measured in PDF "user space".
//
procedure FPDFText_GetCharBox(text_page: HPDFTextPage; index: Integer; var left, right, bottom, top: Double);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDFText_GetCharBox@24'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDFText_CountRects
//      Count number of rectangular areas occupied by a segment of texts.
// Parameters:
//      text_page    -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      start_index  -  Index for the start characters.
//      count        -  Number of characters.
// Return value:
//      Number of rectangles. Zero for error.
// Comments:
//      This function, along with FPDFText_GetRect can be used by applications to detect the position
//      on the page for a text segment, so proper areas can be highlighted or something.
//      FPDFTEXT will automatically merge small character boxes into bigger one if those characters
//      are on the same line and use same font settings.
//
function FPDFText_CountRects(text_page: HPDFTextPage; start_index, count: Integer): Integer;
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDFText_CountRects@12'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDFText_GetRect
//      Get a rectangular area from the result generated by FPDFText_CountRects.
// Parameters:
//      text_page   -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
//      rect_index  -  Zero-based index for the rectangle.
//      left        -  Pointer to a double value receiving the rectangle left boundary.
//      top         -  Pointer to a double value receiving the rectangle top boundary.
//      right       -  Pointer to a double value receiving the rectangle right boundary.
//      bottom      -  Pointer to a double value receiving the rectangle bottom boundary.
// Return Value:
//      None.
//
procedure FPDFText_GetRect(text_page: HPDFTextPage; rect_index: Integer; var left, top, right, bottom: Double);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDFText_GetRect@24'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};

// Function: FPDFText_ClosePage
//      Release all resources allocated for a text page information structure.
// Parameters:
//      text_page  -  Handle to a text page information structure. Returned by FPDFText_LoadPage function.
// Return Value:
//      None.
//
procedure FPDFText_ClosePage(text_page: HPDFTextPage);
  stdcall; external DLL
  {$IFDEF WIN32}name '_FPDFText_ClosePage@4'{$ENDIF}
  {$IFDEF DELAYED}delayed{$ENDIF};


implementation

end.
