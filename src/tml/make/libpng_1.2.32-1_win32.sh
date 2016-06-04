# This is a shell script that calls functions and scripts from
# tml@iki.fi's personal work environment. It is not expected to be
# usable unmodified by others, and is included only for reference.

MOD=libpng
VER=1.2.32
REV=1
ARCH=win32

THIS=${MOD}_${VER}-${REV}_${ARCH}

RUNZIP=${THIS}.zip
DEVZIP=${MOD}-dev_${VER}-${REV}_${ARCH}.zip

HEX=`echo $THIS | md5sum | cut -d' ' -f1`
TARGET=c:/devel/target/$HEX

ZLIB=`latest --arch=${ARCH} zlib`

usedev
usemsvs6

(

set -x

# Avoid the silly "relink" stuff in libtool
sed -e 's/need_relink=yes/need_relink=no # no way --tml/' <ltmain.sh >ltmain.temp && mv ltmain.temp ltmain.sh

patch -p0 <<'EOF' &&
--- Makefile.in
+++ Makefile.in
@@ -1285,7 +1285,7 @@
 # do evil things to libpng to cause libpng12 to be used
 install-exec-hook:
 	cd $(DESTDIR)$(bindir); rm -f libpng-config
-	cd $(DESTDIR)$(bindir); $(LN_S) $(PNGLIB_BASENAME)-config libpng-config
+	-cd $(DESTDIR)$(bindir); $(LN_S) $(PNGLIB_BASENAME)-config libpng-config
 	@set -x;\
 	cd $(DESTDIR)$(libdir);\
 	for ext in a la so sl dylib; do\
EOF

CC='gcc -mtune=pentium3 -mthreads -mms-bitfields' CPPFLAGS="-I /devel/dist/${ARCH}/${ZLIB}/include" LDFLAGS="-L/devel/dist/${ARCH}/${ZLIB}/lib -Wl,--enable-auto-image-base" CFLAGS=-O2 ./configure --disable-static --without-libpng-compat --without-binconfigs --prefix=$TARGET &&
make install &&

rm -f /tmp/$RUNZIP /tmp/$DEVZIP &&

(cd /devel/target/$HEX &&
zip /tmp/$RUNZIP bin/libpng12-0.dll &&
zip -r -D /tmp/$DEVZIP include  &&
zip /tmp/$DEVZIP lib/libpng12.dll.a &&
pexports bin/libpng12-0.dll >lib/libpng.def &&
lib -machine:X86 -def:lib/libpng.def -name:libpng12-0.dll -out:lib/libpng.lib &&
zip /tmp/$DEVZIP lib/libpng.def lib/libpng.lib &&
zip /tmp/$DEVZIP lib/pkgconfig/libpng*.pc &&
zip -r -D /tmp/$DEVZIP share/man
)

) 2>&1 | tee /devel/src/tml/make/$THIS.log &&

(cd /devel && zip /tmp/$DEVZIP src/tml/make/$THIS.{sh,log}) &&
manifestify /tmp/$RUNZIP /tmp/$DEVZIP
