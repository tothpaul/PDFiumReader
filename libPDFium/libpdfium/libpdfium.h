// libdfium v1.0 (c)2018 Execute SARL <contact@execute.fr>

#ifndef PUBLIC_FPDFVIEW_H_
typedef void *FPDF_DOCUMENT;
typedef void *FPDF_PAGE;
typedef void *FPDF_TEXTPAGE;
typedef void *FPDF_ANNOTATION;
#endif
#ifndef WINAPI
typedef long ULONG;
typedef int HDC;
#endif

#define PDFIUM_VERSION 2

typedef int (__stdcall *TWriteProc)(const void *data, int size, void *UserData);

typedef struct TStream TStream;
typedef TStream *PStream;
typedef TStream **IStream;

typedef struct TPDFium TPDFium;
typedef TPDFium *PPDFium;
typedef TPDFium **IPDFium;

typedef struct TPDFPage TPDFPage;
typedef TPDFPage *PPDFPage;
typedef TPDFPage **IPDFPage;

typedef struct TPDFText TPDFText;
typedef TPDFText *PPDFText;
typedef TPDFText **IPDFText;

typedef struct TPDFAnnotation TPDFAnnotation;
typedef TPDFAnnotation *PPDFAnnotation;
typedef TPDFAnnotation **IPDFAnnotation;

typedef struct {
  int Left;
  int Top;
  int Right;
  int Bottom;
} TRect;

typedef struct {
  float Left;
  float Top;
  float Right;
  float Bottom;
} TRectF;

typedef struct {
  double Left;
  double Top;
  double Right;
  double Bottom;
} TRectD;

typedef struct {
  double cx;
  double cy;
} TPointsSize;

struct TStream {
// IUnknown
  int(__stdcall *QueryInterface)(void *intf, void *rrid, void*);
  int(__stdcall *AddRef)(IStream stream);
  int(__stdcall *Release)(IStream stream);
// ISequentialStream
  int(__stdcall *Read)(IStream stream, const void *pv, ULONG cb, ULONG *pcbRead);
  int(__stdcall *Write)(IStream stream, const void *pv, ULONG cb, ULONG *pcbWritten);
};

struct TPDFAnnotation {
// IUnknown
  int(__stdcall *QueryInterface)(void *intf, void *rrid, void*);
  int(__stdcall *AddRef)(IPDFAnnotation annotation);
  int(__stdcall *Release)(IPDFAnnotation annotation);
// IPDFAnnotation
  int(__stdcall *GetSubtype)(IPDFAnnotation annotation);
  int(__stdcall *GetRect)(IPDFAnnotation annotation, TRectF *rect);
  int(__stdcall *SetRect)(IPDFAnnotation annotation, TRectF *rect);
  int(__stdcall *GetString)(IPDFAnnotation annotation, const char *key, char *str, int size);
  int(__stdcall *Remove)(IPDFAnnotation annotation);
// Internal
  PPDFAnnotation Reference;
  int RefCount;
  IPDFPage Page;
  int Index;
  FPDF_ANNOTATION Handle;
};

struct TPDFText {
// IUnknown
  int(__stdcall *QueryInterface)(void *intf, void *rrid, void *out);
  int(__stdcall *AddRef)(IPDFText text);
  int(__stdcall *Release)(IPDFText text);
// IPDFText
  int(__stdcall *CharCount)(IPDFText text);
  int(__stdcall *GetText)(IPDFText text, int Start, int Length, unsigned short *Text);
  int(__stdcall *CharIndexAtPos)(IPDFText text, TPointsSize *size, int distance);
  int(__stdcall *GetRectCount)(IPDFText text, int Start, int Length);
  int(__stdcall *GetRect)(IPDFText text, int Index, TRectD *rect);
// Internal  
  PPDFText Reference;
  int RefCount;
  IPDFPage Page;
  FPDF_TEXTPAGE Handle;
};

struct TPDFPage {
// IUnknown
  int(__stdcall *QueryInterface)(void *intf, void *rrid, void *out);
  int(__stdcall *AddRef)(IPDFPage page);
  int(__stdcall *Release)(IPDFPage page);
// IPDFPage
  int(__stdcall *Render)(IPDFPage page, HDC dc, TRect *rect, int rotation, int flags);
  int(__stdcall *GetAnnotationCount)(IPDFPage page);
  int(__stdcall *GetAnnotation)(IPDFPage page, int annotation_index, IPDFAnnotation *annotation);
  int(__stdcall *GetText)(IPDFPage page, IPDFText *text);
  void(__stdcall *DeviveToPage)(IPDFPage page, TRect *rect, int x, int y, double *px, double *py);
  void(__stdcall *PageToDevice)(IPDFPage page, TRect *rect, double px, double py, int *x, int *y);
	int(__stdcall *GetRotation)(IPDFPage page);
// Internal
  PPDFPage Reference;
  int RefCount;
  IPDFium PDF;
  FPDF_PAGE Handle;
};

struct TPDFium {
// IUnknown
  int(__stdcall *QueryInterface)(void *intf, void *rrid, void *out);
  int(__stdcall *AddRef)(IPDFium pdf);
  int(__stdcall *Release)(IPDFium pdf);
// IPDFium
  int(__stdcall *GetVersion)(IPDFium pdf);
  int(__stdcall *GetError)(IPDFium pdf);
  int(__stdcall *CloseDocument)(IPDFium pdf);
  int(__stdcall *LoadFromFile)(IPDFium pdf, char *filename, char *pwd);
  int(__stdcall *LoadFromMemory)(IPDFium pdf, void *data, int size, char *pwd);
  long(__stdcall *GetPermissions)(IPDFium pdf);
  int(__stdcall *GetPageCount)(IPDFium pdf);
  int(__stdcall *GetPageSize)(IPDFium pdf, int page_index, double *width, double *height);
  int(__stdcall *GetPage)(IPDFium pdf, int page_index, IPDFPage *page);
  int(__stdcall *SaveToStream)(IPDFium pdf, IStream stream);
  int(__stdcall *SaveToProc)(IPDFium pdf, TWriteProc writeProc, void *userData);
// Internal
  PPDFium Reference;
  int RefCount;
  int PageCount;
  int Version;
  FPDF_DOCUMENT Handle;
};

int __stdcall PDF_FreeHandle(void *handle);

int __stdcall PDF_Create(int RequiredVersion, IPDFium *pdf);
int __stdcall PDF_Free(IPDFium pdf);
int __stdcall PDF_GetVersion(IPDFium pdf);
int __stdcall PDF_GetError(IPDFium pdf);
int __stdcall PDF_CloseDocument(IPDFium pdf);
int __stdcall PDF_LoadFromFile(IPDFium pdf, char *filename, char *pwd);
int __stdcall PDF_LoadFromMemory(IPDFium pdf, void *data, int size, char *pwd);
long __stdcall PDF_GetPermissions(IPDFium pdf);
int __stdcall PDF_GetPageCount(IPDFium pdf);
int __stdcall PDF_GetPageSize(IPDFium pdf, int page_index, double *width, double *height);
int __stdcall PDF_GetPage(IPDFium pdf, int page_index, IPDFPage *page);
int __stdcall PDF_SaveToStream(IPDFium pdf, IStream stream);
int __stdcall PDF_SaveToProc(IPDFium pdf, TWriteProc writeProc, void *userData);

int __stdcall PDFPage_Free(IPDFPage page);
int __stdcall PDFPage_Render(IPDFPage page, HDC dc, TRect *rect, int rotation, int flags);
int __stdcall PDFPage_Paint(IPDFPage page, HDC dc, TRect *rect, int annotation);
int __stdcall PDFPage_GetAnnotationCount(IPDFPage page);
int __stdcall PDFPage_GetAnnotation(IPDFPage page, int annotation_index, IPDFAnnotation *annotation);
int __stdcall PDFPage_GetText(IPDFPage page, IPDFText *text);
void __stdcall PDFPage_DeviveToPage(IPDFPage page, TRect *rect, int x, int y, double *px, double *py);
void __stdcall PDFPage_PageToDevice(IPDFPage page, TRect *rect, double px, double py, int *x, int *y);
int __stdcall PDFPage_GetRotation(IPDFPage page);

int __stdcall PDFText_Free(IPDFText text);
int __stdcall PDFText_CharCount(IPDFText text);
int __stdcall PDFText_GetText(IPDFText text, int Start, int Length, unsigned short *Text);
int __stdcall PDFText_CharIndexAtPos(IPDFText text, TPointsSize *size, int distance);
int __stdcall PDFText_GetRectCount(IPDFText text, int Start, int Length);
int __stdcall PDFText_GetRect(IPDFText text, int Index, TRectD *rect);

int __stdcall PDFAnnotation_Free(IPDFAnnotation annotation);
int __stdcall PDFAnnotation_GetSubtype(IPDFAnnotation annotation);
int __stdcall PDFAnnotation_GetRect(IPDFAnnotation annotation, TRectF *rect);
int __stdcall PDFAnnotation_SetRect(IPDFAnnotation annotation, TRectF *rect);
int __stdcall PDFAnnotation_GetString(IPDFAnnotation annotation, char *key, char *str, int size);
