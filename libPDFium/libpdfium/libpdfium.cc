#include <windows.h>
#include "public/fpdfview.h"

#include "public/fpdf_annot.h"
#include "public/fpdf_text.h"
#include "public/fpdf_save.h"
#include "public/fpdf_edit.h"

#include "libpdfium.h"

#define IS_REF(i) i && *i && (*i == &(*(*i))->Reference) 

//#define TRACE
#ifdef TRACE
#include <stdio.h>
DWORD wOut;
#define LOG(s)                                                              \
  {                                                                         \
    AllocConsole();                                                         \
    WriteConsoleA(GetStdHandle(STD_OUTPUT_HANDLE), s, strlen(s), &wOut, 0); \
  }
#define REF(i)                                      \
  if (i == 0 /*|| !*i || (*i != (*i)->Reference)*/) \
    LOG("NULL Interface !!!\n")                     \
  if (*i == 0)                                      \
    LOG("NULL Reference !!!\n")                     \
  if (*i != (*i)->Reference)                        \
    LOG("INVALID Reference\n")                      \
  if (!(*i)->Handle)                                \
  LOG("INVALID HANDLE\n")
#else
#define LOG(s)
#define REF(i)
#endif

// DLL Main

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

// dummy QueryInterface

int WINAPI QueryInterface(void *self, void *rrid, void *out) {
  LOG("QueryInterface\n")
  return 0x80004001; // E_NOTIMPL
}

// generic function
 void WINAPI PDF_FreeHandle(IPDFium pdf) {
 // IUnknown->Release, can be used with any object
  LOG("FreeHandle\n")
  (*pdf)->Release(pdf);
}

// forward
int WINAPI PDF_Free(IPDFium pdf);
int WINAPI PDFPage_Free(IPDFPage page);
int WINAPI PDFText_Free(IPDFText text);

// IPDFAnnotation

int WINAPI PDFAnnotation_AddRef(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_AddRef\n")
  REF(annotation)
  return ++(*annotation)->RefCount;
}

int WINAPI PDFAnnotation_Free(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_Free\n")
  REF(annotation)
  int i = --(*annotation)->RefCount;
  if (i == 0) {
    if ((*annotation)->Handle)
      FPDFPage_CloseAnnot((*annotation)->Handle);
    PDFPage_Free((*annotation)->Page);
    LOG("delete annotation\n")
    delete (*annotation)->Reference;
  }
  return i;
}

int WINAPI PDFAnnotation_GetSubtype(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_GetSubtype\n")
  REF(annotation)
  return FPDFAnnot_GetSubtype((*annotation)->Handle);
}

int WINAPI PDFAnnotation_GetRect(IPDFAnnotation annotation, TRectF *rect) {
  LOG("PDFAnnotation_GetRect\n")
  REF(annotation)
  return FPDFAnnot_GetRect((*annotation)->Handle, (FS_LPRECTF)rect);
}

int WINAPI PDFAnnotation_SetRect(IPDFAnnotation annotation, TRectF *rect) {
  LOG("PDFAnnotation_SetRect\n")
  REF(annotation)
  return FPDFAnnot_SetRect((*annotation)->Handle, (FS_LPRECTF)rect);
}

int WINAPI PDFAnnotation_GetString(IPDFAnnotation annotation, const char *key, char *str, int size) {
  LOG("PDFAnnotation_GetString\n")
  REF(annotation)
  return FPDFAnnot_GetStringValue((*annotation)->Handle, key, (unsigned short *)str, size);
}

int WINAPI PDFAnnotation_Remove(IPDFAnnotation annotation) {
  LOG("PDFAnnotation_Remove\n")
  REF(annotation)
  if (!(*annotation)->Handle) return 0;
  FPDFPage_CloseAnnot((*annotation)->Handle);
  (*annotation)->Handle = 0;
  return FPDFPage_RemoveAnnot((*(*annotation)->Page)->Handle, (*annotation)->Index);
}

// IPDFText

int WINAPI PDFText_AddRef(IPDFText text) {
  LOG("PDFText_AddRef\n")
  REF(text)
  return ++(*text)->RefCount;
}

int WINAPI PDFText_Free(IPDFText text) {
  LOG("PDFText_Free\n")
  REF(text)
  int i = --(*text)->RefCount;
  if (i == 0) {
    FPDFText_ClosePage((*text)->Handle);
    PDFPage_Free((*text)->Page);
    LOG("delete text\n")
    delete (*text)->Reference;
  }
  return i;
}

int WINAPI PDFText_CharCount(IPDFText text) {
  REF(text)
  return FPDFText_CountChars((*text)->Handle);
}

int WINAPI PDFText_GetText(IPDFText text, int Start, int Length, unsigned short *Text) {
  REF(text)
  return FPDFText_GetText((*text)->Handle, Start, Length, Text);
}

int WINAPI PDFText_CharIndexAtPos(IPDFText text, TPointsSize *size, int distance) {
  REF(text)
  return FPDFText_GetCharIndexAtPos((*text)->Handle, size->cx, size->cy, distance, distance);
}

int WINAPI PDFText_GetRectCount(IPDFText text, int Start, int Length) {
  REF(text)
  return FPDFText_CountRects((*text)->Handle, Start, Length);	
}

int WINAPI PDFText_GetRect(IPDFText text, int Index, TRectD *rect) {
  REF(text)
  return FPDFText_GetRect((*text)->Handle, Index, &rect->Left, &rect->Top, &rect->Right, &rect->Bottom);
}

// IPDFPage

int WINAPI PDFPage_AddRef(IPDFPage page) {
  LOG("PDFPage_AddRef\n")
  REF(page)
  return ++(*page)->RefCount;
}

int WINAPI PDFPage_Free(IPDFPage page) {
  LOG("PDFPage_Free\n")
  REF(page)
  int i = --(*page)->RefCount;
  if (i == 0) {
    FPDF_ClosePage((*page)->Handle);
    PDF_Free((*page)->PDF);
    LOG("delete page\n")
    delete (*page)->Reference;
  }
  return i;
}

int WINAPI PDFPage_Render(IPDFPage page, HDC dc, TRect* rect, int rotation, int flags) {
  LOG("PDFPage_Render\n")
  REF(page)
  FPDF_RenderPage(dc, (*page)->Handle, rect->Left, rect->Top, rect->Right - rect->Left, rect->Bottom - rect->Top, rotation, flags);
  return 0;
}

int WINAPI PDFPage_GetAnnotationCount(IPDFPage page) {
  LOG("PDFPage_GetAnnotationCount\n")
  REF(page)
  return FPDFPage_GetAnnotCount((*page)->Handle);
}

int WINAPI PDFPage_GetAnnotation(IPDFPage page, int annotation_index, IPDFAnnotation *annotation) {
  LOG("PDFPage_GetAnnotation\n")
  REF(page)
  if (IS_REF(annotation))
    PDFAnnotation_Free(*annotation);
  FPDF_ANNOTATION Handle = FPDFPage_GetAnnot((*page)->Handle, annotation_index);
  if (Handle) {
    TPDFAnnotation *PDFAnnotation = new TPDFAnnotation();
  // Internal
    (*page)->RefCount++;
    PDFAnnotation->Page = page;
    PDFAnnotation->Index = annotation_index;
    PDFAnnotation->Handle = Handle;
    PDFAnnotation->Reference = PDFAnnotation;
    PDFAnnotation->RefCount = 1;
  // IUnknown
    PDFAnnotation->QueryInterface = QueryInterface;
    PDFAnnotation->AddRef = PDFAnnotation_AddRef;
    PDFAnnotation->Release = PDFAnnotation_Free;
  // IPDFAnnotation
    PDFAnnotation->GetSubtype = PDFAnnotation_GetSubtype;
    PDFAnnotation->GetRect = PDFAnnotation_GetRect;
    PDFAnnotation->SetRect = PDFAnnotation_SetRect;
    PDFAnnotation->GetString = PDFAnnotation_GetString;
    PDFAnnotation->Remove = PDFAnnotation_Remove;
  // Result
    *annotation = &PDFAnnotation->Reference;
    return 0;
  }
  return 1;	
}

int WINAPI PDFPage_GetText(IPDFPage page, IPDFText *text) {
  LOG("PDFPage_GetText\n")
  REF(page)
  if (IS_REF(text))
    PDFText_Free(*text);
  FPDF_TEXTPAGE Handle = FPDFText_LoadPage((*page)->Handle);
  if (Handle) {
    TPDFText *PDFText = new TPDFText();
  // Internal 
    (*page)->RefCount++;
    PDFText->Page = page;
    PDFText->Handle = Handle;
    PDFText->Reference = PDFText;
    PDFText->RefCount = 1;
  // IUnknown
    PDFText->QueryInterface = QueryInterface;
    PDFText->AddRef = PDFText_AddRef;
    PDFText->Release = PDFText_Free;
  // IPDFText
    PDFText->CharCount = PDFText_CharCount;
    PDFText->GetText = PDFText_GetText;
    PDFText->CharIndexAtPos = PDFText_CharIndexAtPos;
    PDFText->GetRectCount = PDFText_GetRectCount;
    PDFText->GetRect = PDFText_GetRect;
  // Result
    *text = &PDFText->Reference;
    return 0;
  }
  return 1;
}

void WINAPI PDFPage_DeviveToPage(IPDFPage page, TRect *rect, int x, int y, double *px, double *py) {
  REF(page)
  FPDF_DeviceToPage((*page)->Handle, rect->Left, rect->Top, rect->Right - rect->Left, rect->Bottom - rect->Top, 0, x, y, px, py);
}

void WINAPI PDFPage_PageToDevice(IPDFPage page, TRect *rect, double px, double py, int *x, int *y) {
  REF(page)
  FPDF_PageToDevice((*page)->Handle, rect->Left, rect->Top, rect->Right - rect->Left, rect->Bottom - rect->Top, 0, px, py, x, y);
}

int WINAPI PDFPage_GetRotation(IPDFPage page) {
  LOG("PDFPage_GetRotation\n")
  REF(page)
  return FPDFPage_GetRotation((*page)->Handle);
}

// IPDFium

int __stdcall PDF_AddRef(IPDFium pdf) {
  LOG("PDF_AddRef\n")
  REF(pdf)
  return ++(*pdf)->RefCount;
}

int WINAPI PDF_Free(IPDFium pdf) {
  LOG("PDF_Free\n")
  REF(pdf)
  int i = --(*pdf)->RefCount;
  if (i == 0) {
   	LOG("FPDF_CloseDocument\n")
    if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
    LOG("delete pdf\n")
    delete (*pdf)->Reference;
  }
  return i;
}

int WINAPI PDF_GetVersion(IPDFium pdf) {
  LOG("PDF_GetVersion\n")
  REF(pdf)
  return (*pdf)->Version;
}

int WINAPI PDF_GetError(IPDFium pdf) {
  LOG("PDF_GetError\n")
  REF(pdf)
  return (int)FPDF_GetLastError();
}

int WINAPI PDF_CloseDocument(IPDFium pdf) {
  LOG("PDF_CloseDocument\n")
  REF(pdf)
  if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
  (*pdf)->Handle = 0;
  return 0;
}

int WINAPI PDF_LoadFromFile(IPDFium pdf, char* filename, char* pwd) {
  LOG("PDF_LoadFromFile\n")
  REF(pdf)
  if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
  (*pdf)->Handle = FPDF_LoadDocument(filename, pwd);
  return (*pdf)->Handle ? 0 : (int)FPDF_GetLastError();
}

int WINAPI PDF_LoadFromMemory(IPDFium pdf, void* data, int size, char* pwd) {
  LOG("PDF_LoadFromMemory\n")
  REF(pdf)	
  if ((*pdf)->Handle) FPDF_CloseDocument((*pdf)->Handle);
  (*pdf)->Handle = FPDF_LoadMemDocument(data, size, pwd);
  return (*pdf)->Handle ? 0 : (int)FPDF_GetLastError();
}

long WINAPI PDF_GetPermissions(IPDFium pdf) {
  REF(pdf)
  return FPDF_GetDocPermissions((*pdf)->Handle);
}

int WINAPI PDF_GetPageCount(IPDFium pdf) {
 LOG("PDF_GetPageCount\n")
  REF(pdf)
  return FPDF_GetPageCount((*pdf)->Handle);
}

int WINAPI PDF_GetPageSize(IPDFium pdf, int page_index, double* width, double* height) {
  LOG("PDF_GetPageSize\n")
  REF(pdf)
  return FPDF_GetPageSizeByIndex((*pdf)->Handle, page_index, width, height);
}

int WINAPI PDF_GetPage(IPDFium pdf, int page_index, IPDFPage* page) {
  LOG("PDF_GetPage\n")
  REF(pdf)
  if (IS_REF(page))
    PDFPage_Free(*page);
  FPDF_PAGE Handle = FPDF_LoadPage((*pdf)->Handle, page_index);
  if (Handle) {
    TPDFPage *PDFPage = new TPDFPage();
  // Internal
    (*pdf)->RefCount++;
    PDFPage->PDF = pdf;
    PDFPage->Handle = Handle;
    PDFPage->Reference = PDFPage;
    PDFPage->RefCount = 1;
  // IUnknown
    PDFPage->QueryInterface = QueryInterface;
    PDFPage->AddRef = PDFPage_AddRef;
    PDFPage->Release = PDFPage_Free;
  // IPDFPage
    PDFPage->Render = PDFPage_Render;
    PDFPage->GetAnnotationCount = PDFPage_GetAnnotationCount;
    PDFPage->GetAnnotation = PDFPage_GetAnnotation;
    PDFPage->GetText = PDFPage_GetText;
    PDFPage->DeviveToPage = PDFPage_DeviveToPage;
    PDFPage->PageToDevice = PDFPage_PageToDevice;
		PDFPage->GetRotation = PDFPage_GetRotation;
  // Result
    *page = &PDFPage->Reference;
    return 0;
  }
  return 1;
}

typedef struct {
  FPDF_FILEWRITE FW;
  TWriteProc writeProc;
  IStream Stream;
} TWriteStream, *PWriteStream;

int WriteStream(struct FPDF_FILEWRITE_* pThis, const void* pData, unsigned long size) {
  ULONG pcbWritten;
  if ((*((PWriteStream)pThis)->Stream)->Write(((PWriteStream)pThis)->Stream, pData, size, &pcbWritten) == 0)
    return pcbWritten;
  return 0;
}

int WINAPI PDF_SaveToStream(IPDFium pdf, IStream stream) {
  LOG("PDF_SaveToStream\n")
  REF(pdf)
  TWriteStream WS;
  WS.FW.version = 1;
  WS.FW.WriteBlock = WriteStream;
  WS.Stream = stream;
  int ret = FPDF_SaveAsCopy((*pdf)->Handle, &WS.FW, 0);
  (*stream)->Release(stream);
  return ret;
}

typedef struct {
  FPDF_FILEWRITE FW;
  TWriteProc writeProc;
  void* userData;
} TFileWrite, *PFileWrite;

int WriteBlock(struct FPDF_FILEWRITE_* pThis, const void* pData, unsigned long size) {
  return ((PFileWrite)pThis)->writeProc(pData, size, ((PFileWrite)pThis)->userData);
}

int WINAPI PDF_SaveToProc(IPDFium pdf, TWriteProc writeProc, void *userData) {
  LOG("PDF_SaveToProc\n")
  REF(pdf)
  TFileWrite FW;
  FW.FW.version = 1;
  FW.FW.WriteBlock = WriteBlock;
  FW.writeProc = writeProc;
  FW.userData = userData;
  return FPDF_SaveAsCopy((*pdf)->Handle, &FW.FW, 0);
}

int initialized = 0;

int WINAPI PDF_Create(int RequestedVersion, IPDFium* pdf) {
  LOG("PDF_Create\n")
  if (RequestedVersion != PDFIUM_VERSION) return -1;
  if (!initialized) {
    LOG("Initialization\n")
    initialized = 1;
    FPDF_InitLibrary();
  }
  if (IS_REF(pdf))
    PDF_Free(*pdf);
  TPDFium *PDF = new TPDFium();
  // Internal
  PDF->Version = 1;
  PDF->Reference = PDF;
  PDF->RefCount = 1;
  PDF->Handle = 0;
  // IUnknown
  PDF->QueryInterface = QueryInterface;
  PDF->AddRef = PDF_AddRef;
  PDF->Release = PDF_Free;
  // IPDFInterface
  PDF->GetVersion = PDF_GetVersion;
  PDF->GetError = PDF_GetError;
  PDF->CloseDocument = PDF_CloseDocument;
  PDF->LoadFromFile = PDF_LoadFromFile;
  PDF->LoadFromMemory = PDF_LoadFromMemory;
  PDF->GetPermissions = PDF_GetPermissions;
  PDF->GetPageCount = PDF_GetPageCount;
  PDF->GetPageSize = PDF_GetPageSize;
  PDF->GetPage = PDF_GetPage;
  PDF->SaveToStream = PDF_SaveToStream;
  PDF->SaveToProc = PDF_SaveToProc;
  // Result
  *pdf = &PDF->Reference;
  return 0;
}
