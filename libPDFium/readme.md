# libPDFium (c)2018-2020 Execute SARL

A PDFium Library designed for Delphi, by a Delphi developper.

it's a x86/x64 Windows library that can be used by any langage afterall

to get a IPDFium object, just call
```
  IPDFium pdf = 0;
  PDF_Create(1, &pdf)
```
all the COM methods are exposed as a raw C API, so you can call 
```
  (*pdf)->LoadFromFile("file.pdf", NULL);
  (*pdf)->Release();
```
or 
```
  PDF_LoadFromFile(pdf, "file.pdf", NULL);
  PDF_Free(pdf);
```

I'm not a C developper, if you need a libpdfium.lib, sorry you'll have to do it yourself, or switch to Delphi and use Execute.libPDFium.pas :)

I know, libpdfium.h exposes the internal members of my objects, but it's not my purpose to use this library from a C project, only from a Delphi one, so I don't care.

I've found how to install rc.exe so I can compile libpdfium.rc !
````
 third_party/depot_tools/download_from_google_storage.bat -s build/toolchain/win/rc/win/rc.exe.sha1 --bucket chromium-browser-clang/rc
````

## Requirements to recompile libPDFium
install [depot_tools](https://www.chromium.org/developers/how-tos/depottools)
````
 set path=%path%;<depot_tools_directory>
 set DEPOT_TOOLS_WIN_TOOLCHAIN=0
 set GCLIENT_PY3=0
````
download PDFium source code
````
 md git
 cd git
 gclient config --unmanaged https://pdfium.googlesource.com/pdfium.git
 gclient sync
````
install libPDFium
1. copy libpdfium/* files to pdfium/libpdfium/*
2. edit Google's pdfium/BUILD.gn to add libpdfium
<pre>
...
group("pdfium_all") {
  testonly = true
  deps = [
    ":pdfium_diff",
    ":pdfium_embeddertests",
    ":pdfium_unittests",
    <b style="color: blue">"//libpdfium:libpdfium",</b>
  ]
  if (pdf_is_standalone) {
    deps += [
      ":fuzzers",
      ":samples",
    ]
  }
}
</pre>
## Recompile libPDFium
````
 cd pdfium
 gn gen out --ide=vs
````
copy "out/args.gn" into "pdfium/out/args.gn"

you can change options in args.gn (debug/release, x86/x64), then

```` 
 gn gen out --ide=vs
 ninja -C out libpdfium
````

Take a coffee or two and you should find libPDFium.dll in the pdfium/out directory.