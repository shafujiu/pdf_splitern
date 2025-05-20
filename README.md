# pdf_splitern

A new Flutter plugin project.

## Getting Started

split
```
PdfSpliternArgs args = PdfSpliternArgs(filePath, outfileDirectory!);
PdfSpliternResult result = await PdfSplitern.split(args);
```

chose pages to creat a new one

```
String? result = await PdfSplitern.splitToMerge(
      filePath: filePath,
      outpath: outPath,
      pageNumbers: [1, 2],
    );
```

