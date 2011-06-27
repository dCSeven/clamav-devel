#!/bin/bash
LIBDIR=/usr/i586-mingw32msvc/lib
NM=i586-mingw32msvc-nm

# DLLs to generate import tables for, in sorted order!
DLLS="advapi32 comctl32 comdlg32 gdi32 kernel32 lz32 mpr ole32 oleaut32 rpcrt4 shell32 user32 version winmm wsock32"

echo "/* Automatically generated file by generate_imports.sh */" >imports.c
echo "/* Do not edit this file. Your changes will be overwritten */" >>imports.c
echo "#include \"imports.h\"" >>imports.c
for i in $DLLS; do
    echo "Generating imports for $i.dll"
    echo "static const struct import_desc $i""_dll_imports[] = {" >>imports.c
    # LANG=C is important, without it we get ignore-case sort with utf8
    $NM $LIBDIR/lib$i.a --defined-only|colrm 1 9|grep ^T|colrm 1 3|LANG=C sort |
    sed -r  -e 's/^([^@]+)@([0-9]+)$/\t{"\1", \2},/' -e 's/^([^,@]+)$/\t{"\1",254},/' >>imports.c
    echo "};" >>imports.c
    echo "static const unsigned $i""_dll_imports_n = sizeof($i""_dll_imports)/sizeof($i""_dll_imports[0]);" >>imports.c
done

echo "const struct dll_desc all_dlls[] = {" >>imports.c
for i in $DLLS; do
    echo -e "\t{\"$i.dll\", $i""_dll_imports, $i""_dll_hooks, &$i""_dll_imports_n, &$i""_dll_hooks_n}," >>imports.c
done
echo "};" >>imports.c
echo "const unsigned all_dlls_n = sizeof(all_dlls)/sizeof(all_dlls[0]);" >>imports.c
