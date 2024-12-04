ARG ALPINE_VERSION=3.17.3
FROM alpine:$ALPINE_VERSION

RUN apk update && apk add \
  autoconf automake bash binutils-gold curl dpkg fakeroot file \
  findutils g++ gcc git make perl shadow tar xz \
  brotli brotli-static \
  bzip2 bzip2-dev bzip2-static \
  curl libcurl curl-static \
  freetype freetype-dev freetype-static \
  gmp-dev \
  libffi libffi-dev \
  libpng libpng-static \
  ncurses-dev ncurses-static \
  openssl-dev openssl-libs-static \
  pcre pcre-dev \
  pcre2 pcre2-dev \
  sdl2 sdl2-dev \
  sdl2_image sdl2_image-dev \
  sdl2_mixer sdl2_mixer-dev \
  sdl2_ttf sdl2_ttf-dev \
  xz xz-dev \
  zlib zlib-dev zlib-static libtool && \
  ln -s /usr/lib/libncursesw.so.6 /usr/lib/libtinfo.so.6

ENV GHCUP_INSTALL_BASE_PREFIX=/usr/local
RUN curl --fail --output /bin/ghcup 'https://downloads.haskell.org/ghcup/x86_64-linux-ghcup' && \
  chmod 0755 /bin/ghcup && \
  ghcup upgrade --target /bin/ghcup && \
  ghcup install cabal --set  && \
  /usr/local/.ghcup/bin/cabal update
ENV PATH="/usr/local/.ghcup/bin:$PATH"

ARG GHC_VERSION=8.10.7
RUN ghcup install ghc "$GHC_VERSION" --set


ENV SODIUM_VERSION=dbb48cc
RUN git clone https://github.com/intersectmbo/libsodium && \
  cd libsodium && \
  git checkout $SODIUM_VERSION && \
  ./autogen.sh && \
  ./configure && \
  make && \
  make check && \
  make install

ENV SECP256K1_VERSION=v0.3.2
RUN git clone --depth 1 --branch ${SECP256K1_VERSION} https://github.com/bitcoin-core/secp256k1 && \
  cd secp256k1 && \
  ./autogen.sh && \
  ./configure --enable-module-schnorrsig --enable-experimental && \
  make && \
  make check && \
  make install

ENV BLST_VERSION=v0.3.11
RUN git clone --depth 1 --branch ${BLST_VERSION} https://github.com/supranational/blst && \
  cd blst && \
  ./build.sh && \
  echo "prefix=/usr/local" > libblst.pc && \
  echo "exec_prefix=\${prefix}" >> libblst.pc && \
  echo "libdir=\${exec_prefix}/lib" >> libblst.pc && \
  echo "includedir=\${prefix}/include" >> libblst.pc && \
  echo "Name: libblst" >> libblst.pc && \
  echo "Description: Multilingual BLS12-381 signature library" >> libblst.pc && \
  echo "URL: https://github.com/supranational/blst" >> libblst.pc && \
  echo "Version: ${BLST_VERSION#v}" >> libblst.pc && \
  echo "Cflags: -I\${includedir}" >> libblst.pc && \
  echo "Libs: -L\${libdir} -lblst" >> libblst.pc && \
  cp libblst.pc /usr/local/lib/pkgconfig/ && \
  cp bindings/blst_aux.h bindings/blst.h bindings/blst.hpp  /usr/local/include/ && \
  cp libblst.a /usr/local/lib

ENV PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/lib/pkgconfig
RUN apk add curl && \
  echo "prefix=/usr" >> /usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "exec_prefix=${prefix}" >> /usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "libdir=${exec_prefix}/lib" >> /usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "includedir=${prefix}/include"  >> /usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "Name: libsystemd" >> /usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "Description: systemd client library" >> /usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "Version: 249" >>/usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "Libs: -L${libdir} -lsystemd" >> /usr/local/lib/pkgconfig/libsystemd.pc && \
  echo "Cflags: -I${includedir}" >> /usr/local/lib/pkgconfig/libsystemd.pc  && \
  curl -L --output libsystemd-249-r0.x86_64.apk 'https://github.com/Artox/alpine-systemd/releases/download/1/libsystemd-249-r0.x86_64.apk' && \
  apk add --allow-untrusted ./libsystemd-249-r0.x86_64.apk


