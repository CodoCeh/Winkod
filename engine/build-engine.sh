#!/bin/bash
# Собирает движок Винкода из открытых исходников и складывает готовое дерево в $OUT.
# Нужны: brew install mingw-w64 bison flex gettext pkgconf freetype gnutls sdl2 и Rosetta.
set -euo pipefail

if [ "$(arch)" != "i386" ]; then
    exec arch -x86_64 /bin/bash "$0" "$@"
fi

CX_SOURCES=https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.3.0.tar.gz
GCENX_LIBS=https://github.com/Gcenx/macOS_Wine_builds/releases/download/11.21/wine-staging-11.21-osx64.tar.xz
DXMT=https://github.com/3Shain/dxmt/releases/download/v0.80/dxmt-v0.80-builtin.tar.gz
DXVK=https://github.com/Gcenx/DXVK-macOS/releases/download/v1.10.3-20230507-repack/dxvk-macOS-async-v1.10.3-20230507-repack-builtin.tar.gz
MONO=https://github.com/madewokherd/wine-mono/releases/download/wine-mono-10.4.1/wine-mono-10.4.1-x86.msi

WORK=${WINKOD_ENGINE_WORK:-$HOME/Library/Caches/winkod-engine}
OUT=${WINKOD_ENGINE_OUT:-$HOME/Library/Application Support/Winkod-build/engine}
DL="$WORK/downloads"
SRC="$WORK/src/sources"
DEPS="$WORK/deps"
BUILD="$WORK/build"
STAGE="$WORK/stage"

case "$WORK" in
    *" "*) echo "ERROR: WINKOD_ENGINE_WORK must not contain spaces" >&2; exit 1 ;;
esac

export PATH=/opt/homebrew/opt/bison/bin:/opt/homebrew/opt/flex/bin:/opt/homebrew/opt/gettext/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin
export MACOSX_DEPLOYMENT_TARGET=14.0

fetch() {
    [ -f "$DL/$2" ] || curl --connect-timeout 30 -fsSL -o "$DL/$2.part" "$1"
    [ -f "$DL/$2" ] || mv "$DL/$2.part" "$DL/$2"
}

mkdir -p "$DL"
fetch "$CX_SOURCES" crossover-sources.tar.gz
fetch "$GCENX_LIBS" gcenx.tar.xz
fetch "$DXMT" dxmt.tar.gz
fetch "$DXVK" dxvk.tar.gz
fetch "$MONO" wine-mono-10.4.1-x86.msi

if [ ! -d "$SRC/wine" ]; then
    mkdir -p "$WORK/src"
    tar xzf "$DL/crossover-sources.tar.gz" -C "$WORK/src"
fi
if [ ! -d "$WORK/gcenx" ]; then
    mkdir -p "$WORK/gcenx"
    tar xJf "$DL/gcenx.tar.xz" -C "$WORK/gcenx"
fi
ln -sfn "$WORK/gcenx/Wine Staging.app/Contents/Resources/wine/lib" "$DEPS"

export CC="clang -arch x86_64" CXX="clang++ -arch x86_64" OBJC="clang -arch x86_64"
export CFLAGS="-O2" CROSSCFLAGS="-O2"
export CPPFLAGS="-I/opt/homebrew/include -I/opt/homebrew/include/freetype2 -I/opt/homebrew/opt/gnutls/include -I/opt/homebrew/opt/nettle/include -I/opt/homebrew/opt/gmp/include"
export LDFLAGS="-L$DEPS -Wl,-headerpad_max_install_names"
export PKG_CONFIG_PATH=/opt/homebrew/lib/pkgconfig
export ac_cv_lib_soname_freetype=libfreetype.6.dylib
export ac_cv_lib_soname_gnutls=libgnutls.30.dylib
export ac_cv_lib_soname_vulkan=libMoltenVK.dylib
export ac_cv_lib_soname_SDL2=libSDL2-2.0.0.dylib
export FREETYPE_CFLAGS="-I/opt/homebrew/include/freetype2" FREETYPE_LIBS="-lfreetype"
export GNUTLS_CFLAGS="-I/opt/homebrew/opt/gnutls/include" GNUTLS_LIBS="-lgnutls"
export SDL2_CFLAGS="-I/opt/homebrew/include/SDL2" SDL2_LIBS="-lSDL2"

mkdir -p "$BUILD"
cd "$BUILD"
if [ ! -f Makefile ]; then
    "$SRC/wine/configure" --prefix="$STAGE" --enable-archs=i386,x86_64 \
        --without-x --without-oss --without-alsa --without-pulse --without-capi --without-v4l2 \
        --disable-tests --disable-winemenubuilder
fi

make -j10 tools/sfnt2fon/sfnt2fon
if [ ! -f tools/sfnt2fon/sfnt2fon.real ]; then
    mv tools/sfnt2fon/sfnt2fon tools/sfnt2fon/sfnt2fon.real
    cat > tools/sfnt2fon/sfnt2fon <<EOF
#!/bin/sh
export DYLD_FALLBACK_LIBRARY_PATH="$DEPS"
exec "$BUILD/tools/sfnt2fon/sfnt2fon.real" "\$@"
EOF
    chmod +x tools/sfnt2fon/sfnt2fon
fi
make -j10
make -j10 install-lib

CAB="$WORK/build-cabextract"
mkdir -p "$CAB"
cd "$CAB"
[ -f Makefile ] || "$SRC/cabextract/configure"
make -j10 cabextract

rm -rf "$OUT"
mkdir -p "$OUT/bin" "$OUT/lib/wine" "$OUT/lib64" "$OUT/lib/dxmt" "$OUT/lib/dxvk" "$OUT/share/wine/mono"

cp -p "$STAGE/bin/wine" "$OUT/bin/wineloader"
cp -p "$STAGE/bin/wineserver" "$OUT/bin/wineserver"
cp -p "$CAB/cabextract" "$OUT/bin/cabextract"
for alias in regedit regsvr32 wineboot winecfg winepath winecons winefile winedbg msiexec msidb notepad start; do
    ln -sf wineloader "$OUT/bin/$alias"
done

cp -Rp "$STAGE/lib/wine/i386-windows" "$STAGE/lib/wine/x86_64-windows" "$STAGE/lib/wine/x86_64-unix" "$OUT/lib/wine/"
find "$OUT/lib/wine" -name '*.a' -delete
i686-w64-mingw32-strip --strip-unneeded "$OUT"/lib/wine/i386-windows/*.dll
x86_64-w64-mingw32-strip --strip-unneeded "$OUT"/lib/wine/x86_64-windows/*.dll
strip -x "$OUT"/lib/wine/x86_64-unix/*.so "$OUT/bin/wineloader" "$OUT/bin/wineserver"
install_name_tool -change libinotify.dylib @executable_path/../lib64/libinotify.dylib "$OUT/bin/wineserver"
install_name_tool -change libinotify.dylib @loader_path/../../../lib64/libinotify.dylib "$OUT/lib/wine/x86_64-unix/winebus.so"
install_name_tool -change libpcap.dylib @loader_path/../../../lib64/libpcap.dylib "$OUT/lib/wine/x86_64-unix/wpcap.so"
codesign --force --sign - "$OUT/bin/wineserver" "$OUT/lib/wine/x86_64-unix/winebus.so" "$OUT/lib/wine/x86_64-unix/wpcap.so"

python3 - "$DEPS" "$OUT/lib64" <<'EOF'
import os, shutil, subprocess, sys
deps, out = sys.argv[1:]
todo = ["libfreetype.6.dylib", "libgnutls.30.dylib", "libMoltenVK.dylib",
        "libSDL2-2.0.0.dylib", "libpcap.A.dylib", "libpcap.dylib", "libinotify.dylib"]
seen = set()
while todo:
    name = todo.pop()
    if name in seen:
        continue
    seen.add(name)
    path = os.path.join(deps, name)
    links = subprocess.check_output(["otool", "-L", path], text=True).splitlines()[1:]
    for line in links:
        dep = line.strip().split(" ")[0]
        if not dep.startswith(("/usr/lib", "/System")):
            todo.append(os.path.basename(dep))
    real = os.path.realpath(path)
    if not os.path.exists(os.path.join(out, os.path.basename(real))):
        shutil.copy2(real, out)
    if os.path.basename(real) != name:
        os.symlink(os.path.basename(real), os.path.join(out, name))
EOF

tar xzf "$DL/dxmt.tar.gz" --strip-components=1 -C "$OUT/lib/dxmt"
tar xzf "$DL/dxvk.tar.gz" --strip-components=1 -C "$OUT/lib/dxvk"

cp -p "$STAGE/share/wine/wine.inf" "$OUT/share/wine/"
cp -Rp "$STAGE/share/wine/nls" "$STAGE/share/wine/fonts" "$STAGE/share/wine/winmd" "$OUT/share/wine/"
cp -p "$DL/wine-mono-10.4.1-x86.msi" "$OUT/share/wine/mono/"
cp -p "$SRC/wine/COPYING.LIB" "$OUT/LICENSE"

du -sh "$OUT"
