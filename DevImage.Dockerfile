

# BSD 3-Clause License
#
# Copyright (c) 2021, Intel Corporation
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# This file is automatically generated from .m4 template.
# To update, modify the template and regenerate.
FROM ubuntu:18.04


RUN mkdir -p /opt/build && mkdir -p /opt/dist

ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    g++ ca-certificates wget make libcurl4-gnutls-dev zlib1g-dev && \
  rm -rf /var/lib/apt/lists/*

# build cmake
ARG CMAKE_REPO=https://cmake.org/files
RUN cd /opt/build && \
    wget -O - ${CMAKE_REPO}/v3.21/cmake-3.21.3.tar.gz | tar xz && \
    cd cmake-3.21.3 && \
    ./bootstrap --prefix=/usr/local --system-curl && \
    make -j$(nproc) && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget tar g++ make libtool autoconf && \
  rm -rf /var/lib/apt/lists/*

# build openssl
ARG OPENSSL_REPO=https://github.com/openssl/openssl/archive/OpenSSL_1_1_1l.tar.gz
RUN cd /opt/build && \
    wget -O - ${OPENSSL_REPO} | tar xz && \
    cd openssl-OpenSSL_1_1_1l && \
    ./config no-ssl3 shared --prefix=/usr/local/ssl --openssldir=/usr/local/ssl -fPIC -Wl,-rpath=/usr/local/ssl/lib && \
    make depend && \
    make -s V=0 && \
    make install DESTDIR=/opt/dist && \
    (cd /opt/dist && mkdir -p ./usr/local/lib/pkgconfig && mv ./usr/local/ssl/lib/pkgconfig/*.pc ./usr/local/lib/pkgconfig/) && \
    make install && \
    (mkdir -p /usr/local/lib/pkgconfig && mv /usr/local/ssl/lib/pkgconfig/*.pc /usr/local/lib/pkgconfig/)

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget tar g++ make && \
  rm -rf /var/lib/apt/lists/*

# build yasm
# ARG YASM_REPO=https://www.tortall.net/projects/yasm/releases/yasm-YASM_VER.tar.gz
# At the time of 21.6 Release, yasm official site above had certificate problem, hence pulling from Dockerfiles-Resources.
ARG YASM_REPO=https://github.com/OpenVisualCloud/Dockerfiles-Resources/raw/master/yasm-1.3.0.tar.gz

RUN cd /opt/build && \
    wget -O - ${YASM_REPO} | tar xz
RUN cd /opt/build/yasm-1.3.0 && \
    # TODO remove the line below whether no other component inside this project requires it.
    # `sed -i "s/) ytasm.*/)/" Makefile.in' && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib && \
    make -j $(nproc) && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget tar g++ make git && \
  rm -rf /var/lib/apt/lists/*

# build svt-hevc
ARG SVT_HEVC_REPO=https://github.com/OpenVisualCloud/SVT-HEVC
RUN cd /opt/build && \
    git clone -b v1.5.1 --depth 1 ${SVT_HEVC_REPO}
RUN cd /opt/build/SVT-HEVC/Build/linux && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_INSTALL_LIBDIR=/usr/local/lib -DCMAKE_ASM_NASM_COMPILER=yasm ../.. && \
    make -j $(nproc) && \
    make install DESTDIR=/opt/dist && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget g++ autoconf libtool autotools-dev automake make && \
  rm -rf /var/lib/apt/lists/*

# build libfdkaac
ARG LIBFDKAAC_REPO=https://github.com/mstorsjo/fdk-aac/archive/v2.0.2.tar.gz
RUN cd /opt/build && \
    wget -O - ${LIBFDKAAC_REPO} | tar xz && \
    cd fdk-aac-2.0.2 && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib --enable-shared && \
    make -j$(nproc) && \
    make install DESTDIR=/opt/dist && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget tar g++ make bzip2 && \
  rm -rf /var/lib/apt/lists/*

# build nasm
ARG NASM_REPO=https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.bz2
RUN cd /opt/build && \
    wget -O - ${NASM_REPO} | tar xj && \
    cd nasm-2.15.05 && \
    ./autogen.sh && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib && \
     make -j$(nproc) && \
     make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git make autoconf && \
  rm -rf /var/lib/apt/lists/*

# build libvpx
ARG LIBVPX_REPO=https://chromium.googlesource.com/webm/libvpx.git
RUN cd /opt/build && \
    git clone ${LIBVPX_REPO} -b v1.10.0 --depth 1 && \
    cd libvpx && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib --enable-shared --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=nasm && \
    make -j$(nproc) && \
    make install DESTDIR=/opt/dist && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git make autoconf && \
  rm -rf /var/lib/apt/lists/*

# build libx264
ARG LIBX264_REPO=https://github.com/mirror/x264
RUN cd /opt/build && \
    git clone ${LIBX264_REPO} -b stable --depth 1 && \
    cd x264 && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib \
        --enable-shared && \
    make -j$(nproc) && \
    make install DESTDIR=/opt/dist && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates gcc g++ make wget python3-numpy ccache libeigen3-dev && \
  rm -rf /var/lib/apt/lists/*

# build opencv
ARG OPENCV_REPO=https://github.com/opencv/opencv/archive/4.5.2.tar.gz
RUN cd /opt/build && \
  wget -O - ${OPENCV_REPO} | tar xz
# TODO: file a bug against opencv since they do not accept full libdir
RUN cd /opt/build/opencv-4.5.2 && mkdir build && cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DOPENCV_GENERATE_PKGCONFIG=ON \
    -DBUILD_DOCS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_TESTS=OFF \
    .. && \
  make -j $(nproc) && \
  make install DESTDIR=/opt/dist && \
  make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates gcc g++ git libboost-all-dev libgtk2.0-dev libgtk-3-dev libtool libusb-1.0-0-dev make python python-yaml xz-utils libnuma-dev ocl-icd-opencl-dev opencl-headers && \
  rm -rf /var/lib/apt/lists/*

# build dldt
ARG DLDT_REPO=https://github.com/openvinotoolkit/openvino.git
RUN git clone -b 2021.4.1 --depth 1 ${DLDT_REPO} /opt/build/openvino && \
  cd /opt/build/openvino && \
  git submodule update --init --recursive

# TODO:
# Perform make install of openvino instead of manually copying build artifacts.
#
# For now, only ngraph target is installed using make install (it auto-generates .cmake
# files during install stage, so they can be later used by other projects).

RUN cd /opt/build/openvino && \
    sed -i s/-Werror//g $(grep -ril Werror inference-engine/thirdparty/) && \
  mkdir build && cd build && \
  cmake \
    -DCMAKE_INSTALL_PREFIX=/usr/local/openvino \
    -DENABLE_CPPLINT=OFF \
    -DENABLE_GNA=OFF \
    -DENABLE_VPU=OFF \
    -DENABLE_OPENCV=OFF \
    -DENABLE_MKL_DNN=ON \
    -DENABLE_CLDNN=ON \
    -DENABLE_SAMPLES=OFF \
    -DENABLE_TESTS=OFF \
    -DBUILD_TESTS=OFF \
    -DTREAT_WARNING_AS_ERROR=OFF \
    -DNGRAPH_WARNINGS_AS_ERRORS=OFF \
    -DNGRAPH_COMPONENT_PREFIX=inference-engine/ \
    -DNGRAPH_UNIT_TEST_ENABLE=OFF \
    -DNGRAPH_TEST_UTIL_ENABLE=OFF \
    .. && \
  make -j $(nproc) && \
  make -C ngraph install && \
  make -C ngraph install DESTDIR=/opt/dist && \
  rm -rf ../bin/intel64/Release/lib/libgtest* && \
  rm -rf ../bin/intel64/Release/lib/libgmock* && \
  rm -rf ../bin/intel64/Release/lib/libmock* && \
  rm -rf ../bin/intel64/Release/lib/libtest*

ARG CUSTOM_IE_DIR=/usr/local/openvino/inference-engine
ARG CUSTOM_IE_LIBDIR=${CUSTOM_IE_DIR}/lib/intel64
ENV CUSTOM_DLDT=${CUSTOM_IE_DIR}

ENV InferenceEngine_DIR=/usr/local/openvino/inference-engine/share
ENV TBB_DIR=/usr/local/openvino/inference-engine/external/tbb/cmake
ENV ngraph_DIR=/usr/local/openvino/deployment_tools/ngraph/cmake

RUN cd /opt/build && \
  mkdir -p ${CUSTOM_IE_DIR}/include && \
  mkdir -p /opt/dist/${CUSTOM_IE_DIR}/include && \
  cp -r openvino/inference-engine/include/* ${CUSTOM_IE_DIR}/include && \
  cp -r openvino/inference-engine/ie_bridges/c/include/* ${CUSTOM_IE_DIR}/include && \
  cp -r openvino/inference-engine/include/* /opt/dist/${CUSTOM_IE_DIR}/include && \
  cp -r openvino/inference-engine/ie_bridges/c/include/* /opt/dist/${CUSTOM_IE_DIR}/include && \
  \
  mkdir -p ${CUSTOM_IE_LIBDIR} && \
  mkdir -p /opt/dist/${CUSTOM_IE_LIBDIR} && \
  cp -r openvino/bin/intel64/Release/lib/* ${CUSTOM_IE_LIBDIR} && \
  cp -r openvino/bin/intel64/Release/lib/* /opt/dist/${CUSTOM_IE_LIBDIR} && \
  \
  mkdir -p ${CUSTOM_IE_DIR}/src && \
  mkdir -p /opt/dist/${CUSTOM_IE_DIR}/src && \
  cp -r openvino/inference-engine/src/* ${CUSTOM_IE_DIR}/src/ && \
  cp -r openvino/inference-engine/src/* /opt/dist/${CUSTOM_IE_DIR}/src/ && \
  \
  mkdir -p ${CUSTOM_IE_DIR}/share && \
  mkdir -p /opt/dist/${CUSTOM_IE_DIR}/share && \
  mkdir -p ${CUSTOM_IE_DIR}/external/ \
  mkdir -p /opt/dist/${CUSTOM_IE_DIR}/external && \
  cp -r openvino/build/share/* ${CUSTOM_IE_DIR}/share/ && \
  cp -r openvino/build/share/* /opt/dist/${CUSTOM_IE_DIR}/share/ && \
  cp -r openvino/inference-engine/temp/tbb ${CUSTOM_IE_DIR}/external/ && \
  cp -r openvino/inference-engine/temp/tbb /opt/dist/${CUSTOM_IE_DIR}/external/ && \
  \
  mkdir -p "${CUSTOM_IE_LIBDIR}/pkgconfig"

RUN { \
  echo "prefix=${CUSTOM_IE_DIR}"; \
  echo "libdir=${CUSTOM_IE_LIBDIR}"; \
  echo "includedir=${CUSTOM_IE_DIR}/include"; \
  echo ""; \
  echo "Name: DLDT"; \
  echo "Description: Intel Deep Learning Deployment Toolkit"; \
  echo "Version: 5.0"; \
  echo ""; \
  echo "Libs: -L\${libdir} -linference_engine -linference_engine_c_api"; \
  echo "Cflags: -I\${includedir}"; \
  } > ${CUSTOM_IE_LIBDIR}/pkgconfig/openvino.pc && \
  mkdir -p /opt/dist/usr/local/lib/pkgconfig && \
  cp ${CUSTOM_IE_LIBDIR}/pkgconfig/openvino.pc /opt/dist/usr/local/lib/pkgconfig

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential ca-certificates wget patch git libass-dev  && \
  rm -rf /var/lib/apt/lists/*

# build ffmpeg
ARG FFMPEG_REPO=https://github.com/FFmpeg/FFmpeg/archive/n4.4.tar.gz
RUN cd /opt/build && \
    wget -O - ${FFMPEG_REPO} | tar xz

RUN cd /opt/build/FFmpeg-n4.4 && \
    patch -p1 < /opt/build/SVT-HEVC/ffmpeg_plugin/n4.4-0001-lavc-svt_hevc-add-libsvt-hevc-encoder-wrapper.patch || true
#ifdef(`BUILD_SVT_VP9',`FFMPEG_PATCH_SVT_VP9(BUILD_HOME/FFmpeg-FFMPEG_VER)')dnl
#ifdef(`BUILD_DLDT',`FFMPEG_PATCH_ANALYTICS(BUILD_HOME/FFmpeg-FFMPEG_VER)')dnl
#ifdef(`BUILD_OPENVINO',`FFMPEG_PATCH_ANALYTICS(BUILD_HOME/FFmpeg-FFMPEG_VER)')dnl

ARG FFMPEG_PATCHES_RELEASE_REPO=https://github.com/VCDP/CDN.git

RUN cd /opt/build && \
    git clone ${FFMPEG_PATCHES_RELEASE_REPO} && \
    cd /opt/build/FFmpeg-n4.4 && \
    patch -p1 < /opt/build/CDN/FFmpeg_patches/0001-Add-SVT-HEVC-FLV-support-on-FFmpeg.patch;

ARG FFMPEG_1TN_PATCH_REPO=https://raw.githubusercontent.com/OpenVisualCloud/Dockerfiles-Resources/master/n4.4-enhance_1tn_performance.patch
RUN cd /opt/build/FFmpeg-n4.4 && \
    wget -O - ${FFMPEG_1TN_PATCH_REPO} | patch -p1;

RUN cd /opt/build/FFmpeg-n4.4 && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib --enable-shared --disable-static --disable-doc --disable-htmlpages \
    --disable-manpages --disable-podpages --disable-txtpages \
    --extra-cflags=-w     --enable-nonfree     --enable-libass         --disable-xlib --disable-sdl2     --disable-hwaccels         --disable-vaapi             --enable-libfdk-aac         --enable-libvpx         --enable-gpl --enable-libx264             --enable-libsvthevc                 && make -j$(nproc) && \
    make install DESTDIR=/opt/dist && \
    make install

RUN cd /opt/build/opencv-4.5.2/build && \
  rm -rf ./* && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DOPENCV_GENERATE_PKGCONFIG=ON \
    -DBUILD_DOCS=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_PERF_TESTS=OFF \
    -DBUILD_TESTS=OFF \
    .. && \
  cd modules/videoio && \
  make -j $(nproc) && \
  cp -f ../../lib/libopencv_videoio.so.4.5.2 /opt/dist/usr/local/lib

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python3-pip ninja-build python3-setuptools && \
  rm -rf /var/lib/apt/lists/*

# build meson
ARG MESON_REPO=https://github.com/mesonbuild/meson
RUN git clone ${MESON_REPO}; \
    cd meson; \
    git checkout 0.59.1; \
    python3 setup.py install;

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates tar g++ wget pkg-config libglib2.0-dev flex bison gobject-introspection libgirepository1.0-dev && \
  rm -rf /var/lib/apt/lists/*

# build gst-core
ARG GSTCORE_REPO=https://github.com/GStreamer/gstreamer/archive/1.19.1.tar.gz
RUN cd /opt/build && \
    wget -O - ${GSTCORE_REPO} | tar xz
RUN cd /opt/build/gstreamer-1.19.1 && \
    meson build --libdir=/usr/local/lib --libexecdir=/usr/local/lib \
    --prefix=/usr/local --buildtype=plain \
    -Dbenchmarks=disabled \
    -Dexamples=disabled \
    -Dtests=disabled \
    -Ddoc=disabled \
    -Dintrospection=enabled \
    -Dgtk_doc=disabled && \
    cd build && \
    ninja install && \
    DESTDIR=/opt/dist ninja install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates tar g++ gobjc wget pkg-config libglib2.0-dev flex bison gobject-introspection libgirepository1.0-dev libasound2-dev  && \
  rm -rf /var/lib/apt/lists/*

# build gst-plugin-base
ARG GSTBASE_REPO=https://github.com/GStreamer/gst-plugins-base/archive/1.19.1.tar.gz
RUN cd /opt/build && \
  wget -O - ${GSTBASE_REPO} | tar xz
RUN cd /opt/build/gst-plugins-base-1.19.1 && \
  meson build \
    --prefix=/usr/local \
    --libdir=/usr/local/lib \
    --libexecdir=/usr/local/lib \
    --buildtype=plain \
    -Dexamples=disabled \
    -Dtests=disabled \
    -Ddoc=disabled \
    -Dintrospection=enabled \
    -Dgtk_doc=disabled \
    -Dalsa=enabled \
    -Dpango=disabled \
    -Dtheora=disabled \
    -Dlibvisual=disabled \
    -Dgl=disabled \
  && cd build && \
  ninja install && \
  DESTDIR=/opt/dist ninja install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git ca-certificates tar g++ wget pkg-config libglib2.0-dev flex bison libgdk-pixbuf2.0-dev  && \
  rm -rf /var/lib/apt/lists/*

# build gst-plugin-good
ARG GSTGOOD_REPO=https://github.com/GStreamer/gst-plugins-good/archive/1.19.1.tar.gz
RUN cd /opt/build && \
    wget -O - ${GSTGOOD_REPO} | tar xz
RUN cd /opt/build/gst-plugins-good-1.19.1 && \
    meson build --libdir=/usr/local/lib --libexecdir=/usr/local/lib \
    --prefix=/usr/local --buildtype=plain \
    -Dexamples=disabled \
    -Dtests=disabled \
    -Ddoc=disabled \
    -Dgtk_doc=disabled \
    -Dgdk-pixbuf=enabled \
    -Djpeg=disabled \
    -Dpng=disabled \
    -Disomp4=disabled \
    -Dsoup=disabled \
    -Dvpx=enabled \
    && cd build && \
    ninja install && \
    DESTDIR=/opt/dist ninja install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates tar g++ wget pkg-config libglib2.0-dev flex bison gobject-introspection libgirepository1.0-dev libcurl4-gnutls-dev librtmp-dev  && \
  rm -rf /var/lib/apt/lists/*

# build gst-plugin-bad
ARG GSTBAD_REPO=https://github.com/GStreamer/gst-plugins-bad/archive/1.19.1.tar.gz
RUN cd /opt/build && \
    wget -O - ${GSTBAD_REPO} | tar xz && \
    cd gst-plugins-bad-1.19.1 && \
    meson build \
      --prefix=/usr/local \
      --libdir=/usr/local/lib \
      --libexecdir=/usr/local/lib \
      --buildtype=plain \
      -Ddoc=disabled \
      -Dexamples=disabled \
      -Dgtk_doc=disabled \
      -Dtests=disabled \
      -Dintrospection=enabled \
      -Dgst_player_tests=false \
      -Drtmp=enabled \
      -Dx265=disabled \
      -Drsvg=disabled \
      -Dfdkaac=disabled \
    && cd build && \
    ninja install && \
    DESTDIR=/opt/dist ninja install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates tar g++ wget pkg-config libglib2.0-dev flex bison && \
  rm -rf /var/lib/apt/lists/*

# build gst-plugin-ugly
ARG GSTUGLY_REPO=https://github.com/GStreamer/gst-plugins-ugly/archive/1.19.1.tar.gz
RUN cd /opt/build && \
    wget -O - ${GSTUGLY_REPO} | tar xz
RUN cd /opt/build/gst-plugins-ugly-1.19.1 && \
    meson build --libdir=/usr/local/lib --libexecdir=/usr/local/lib \
    --prefix=/usr/local --buildtype=plain \
    -Ddoc=disabled \
    -Dgtk_doc=disabled \
    -Dx264=enabled \
    && cd build && \
    ninja install && \
    DESTDIR=/opt/dist ninja install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates tar g++ wget  && \
  rm -rf /var/lib/apt/lists/*

# build gst-plugin-libav
ARG GSTLIBAV_REPO=https://github.com/GStreamer/gst-libav/archive/1.19.1.tar.gz
RUN cd /opt/build && \
    wget -O - ${GSTLIBAV_REPO} | tar xz
RUN cd /opt/build/gst-libav-1.19.1 && \
    meson build --libdir=/usr/local/lib --libexecdir=/usr/local/lib \
    --prefix=/usr/local --buildtype=plain \
    -Dgtk_doc=disabled && \
    cd build && \
    ninja install && \
    DESTDIR=/opt/dist ninja install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git ocl-icd-opencl-dev opencl-headers pkg-config libpython3-dev python-gi-dev ca-certificates libva-dev && \
  rm -rf /var/lib/apt/lists/*

# build gst-plugin-gva
# formerly https://github.com/opencv/gst-video-analytics
ARG GVA_REPO=https://github.com/openvinotoolkit/dlstreamer_gst.git
# TODO: This is a workaround for a bug in dlstreamer_gst
ENV LIBRARY_PATH=/usr/local/lib
RUN git clone -b v1.5.2 --depth 1 $GVA_REPO /opt/build/gst-video-analytics && \
    cd /opt/build/gst-video-analytics && \
    git submodule update --init && \
    sed -i "195s/) {/||g_strrstr(name, \"image\")) {/" gst/elements/gvapython/python_callback.cpp && \
    mkdir -p build && cd build && \
    cmake \
        -DVERSION_PATCH="$(git rev-list --count --first-parent HEAD)" \
        -DGIT_INFO=git_"$(git rev-parse --short HEAD)" \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
        -DCMAKE_BUILD_TYPE=Release \
        -DDISABLE_SAMPLES=ON \
        -DENABLE_PAHO_INSTALLATION=OFF \
        -DENABLE_RDKAFKA_INSTALLATION=OFF \
        -DENABLE_VAAPI=OFF \
        -DENABLE_VAS_TRACKER=ON \
        -DENABLE_AUDIO_INFERENCE_ELEMENTS=OFF \
        -Dwith_drm=no \
        -Dwith_x11=no \
        -Dwith_glx=no \
        -Dwith_wayland=no \
        -Dwith_egl=no \
        -DMQTT=0 \
        -DKAFKA=0 \
        .. \
    && make -j $(nproc) \
    && make install \
    && make install DESTDIR=/opt/dist
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib/gstreamer-1.0/:/usr/local/lib/

RUN cp -r  /opt/build/gst-video-analytics/build/intel64/Release/lib/* /usr/local/lib/gstreamer-1.0/.
RUN cp -r  /opt/build/gst-video-analytics/build/intel64/Release/lib/* /opt/dist//usr/local/lib/gstreamer-1.0/.
ENV GST_PLUGIN_PATH=${GST_PLUGIN_PATH}:/usr/local/lib/gstreamer-1.0/

RUN mkdir -p /opt/intel/dl_streamer/python && \
    cp -r /opt/build/gst-video-analytics/python/* /opt/intel/dl_streamer/python

ENV PYTHONPATH=${PYTHONPATH}:/opt/intel/dl_streamer/python
RUN mkdir -p /opt/dist/opt/intel/dl_streamer/python && \
    cp -r /opt/build/gst-video-analytics/python/* /opt/dist/opt/intel/dl_streamer/python

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates tar g++ wget gtk-doc-tools uuid-dev python-gi-dev python3-dev libtool-bin libpython3-dev libpython3-stdlib libpython3-all-dev  && \
  rm -rf /var/lib/apt/lists/*
ARG GSTPYTHON_REPO=https://gstreamer.freedesktop.org/src/gst-python/gst-python-1.19.1.tar.xz
RUN cd /opt/build && \
    wget -O - ${GSTPYTHON_REPO} | tar xJ
RUN cd /opt/build/gst-python-1.19.1 && \
#WORKAROUND: https://gitlab.freedesktop.org/gstreamer/gst-python/-/merge_requests/30/diffs

    meson build --libdir=/usr/local/lib --libexecdir=/usr/local/lib \
    --prefix=/usr/local --buildtype=plain \
    -Dpython=/usr/bin/python3 -Dlibpython-dir=/usr/lib/x86_64-linux-gnu/  \
    -Dpygi-overrides-dir=/usr/lib/python3/dist-packages/gi/overrides \
    -Dgtk_doc=disabled && \
    cd build && \
    ninja install && \
    DESTDIR=/opt/dist ninja install


RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget bzip2 && \
  rm -rf /var/lib/apt/lists/*

# Build OpenH264
ARG OPENH264_SRC_REPO=https://github.com/cisco/openh264/archive/v1.7.0.tar.gz
ARG OPENH264_BIN_REPO=https://github.com/cisco/openh264/releases/download/v1.7.0/libopenh264-1.7.0-linux64.4.so.bz2
RUN cd /opt/build && \
    wget -O - ${OPENH264_SRC_REPO} | tar xz openh264-1.7.0/codec/api && \
    cd openh264-1.7.0 && \
    (mkdir -p /usr/local/include/openh264 && cp -r codec /usr/local/include/openh264) && \
    (mkdir -p /opt/dist/usr/local/include/openh264 && cp -r codec /opt/dist/usr/local/include/openh264)

RUN cd /usr/local/lib && \
    wget -O - ${OPENH264_BIN_REPO} | bunzip2 > libopenh264.so.4 && \
    ln -s -v libopenh264.so.4 libopenh264.so && \
    cd /opt/dist/usr/local/lib && \
    cp -r /usr/local/lib/libopenh264.so.4 . && \
    ln -s -v libopenh264.so.4 libopenh264.so

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git make autoconf gcc && \
  rm -rf /var/lib/apt/lists/*

# build libre
ARG LIBRE_REPO=https://github.com/creytiv/re.git
RUN cd /opt/build && \
    git clone ${LIBRE_REPO} -b v0.5.0 --depth 1 && \
    cd re && \
    make SYSROOT_ALT=/usr RELEASE=1 && \
    make install SYSROOT_ALT=/usr RELEASE=1 PREFIX=/usr && \
    make SYSROOT_ALT=/opt/dist/usr RELEASE=1 && \
    make install SYSROOT_ALT=/opt/dist/usr RELEASE=1 PREFIX=/opt/dist/usr

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget make gcc libglib2.0-dev patch && \
  rm -rf /var/lib/apt/lists/*

# build libnice
ARG LIBNICE_REPO=http://nice.freedesktop.org/releases/libnice-0.1.4.tar.gz
RUN cd /opt/build && \
    wget -O - ${LIBNICE_REPO} | tar xz


ARG LIBNICE_PATCH_REPO=https://github.com/open-webrtc-toolkit/owt-server/archive/v5.0.tar.gz

RUN cd /opt/build/libnice-0.1.4 && \
    wget -O - ${LIBNICE_PATCH_REPO} | tar xz && \
    patch -p1 < owt-server-5.0/scripts/patches/libnice014-agentlock.patch && \
    patch -p1 < owt-server-5.0/scripts/patches/libnice014-agentlock-plus.patch && \
    patch -p1 < owt-server-5.0/scripts/patches/libnice014-removecandidate.patch && \
    patch -p1 < owt-server-5.0/scripts/patches/libnice014-keepalive.patch && \
    patch -p1 < owt-server-5.0/scripts/patches/libnice014-startcheck.patch && \
    patch -p1 < owt-server-5.0/scripts/patches/libnice014-closelock.patch


RUN cd /opt/build/libnice-0.1.4 && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib && \
    make -j$(nproc) -s V=0 && \
    make install DESTDIR=/opt/dist && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget automake make gcc && \
  rm -rf /var/lib/apt/lists/*

# build usrsctp
ARG USRSCTP_REPO=https://github.com/sctplab/usrsctp/archive/0.9.5.0.tar.gz
RUN cd /opt/build && \
    wget -O - ${USRSCTP_REPO} | tar xz && \
    cd usrsctp-* && \
    ./bootstrap && \
    ./configure --prefix=/usr/local --libdir=/usr/local/lib && \
    make -j$(nproc) && \
    make install DESTDIR=/opt/dist && \
    make install

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates wget && \
  rm -rf /var/lib/apt/lists/*

# build jsonhpp
ARG JSONHPP_REPO=https://github.com/nlohmann/json/releases/download/v3.6.1/json.hpp
RUN wget -O /usr/include/json.hpp ${JSONHPP_REPO}

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget ca-certificates xz-utils && \
  rm -rf /var/lib/apt/lists/*

# build node
ARG NODE_REPO=https://nodejs.org/dist/v10.24.1/node-v10.24.1-linux-x64.tar.xz
RUN cd /opt/build && \
    wget -O - ${NODE_REPO} | tar xJ && \
    cp node-v10.24.1-linux-x64/* /usr/local -rf && \
    rm -rf node-v10.24.1-linux-x64

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git gcc npm python libglib2.0-dev libboost-thread-dev libboost-system-dev liblog4cxx-dev libsrtp2-dev pkg-config && \
  rm -rf /var/lib/apt/lists/*

# Install npm modules
RUN npm install -g --loglevel error node-gyp@6.1.0 grunt-cli underscore jsdoc

# Get owt-server Source
ARG OWT_REPO=https://github.com/open-webrtc-toolkit/owt-server
RUN cd /opt/build && \
    git clone -b master ${OWT_REPO} && \
    cd owt-server && \
    git reset --hard v5.0

# Prep OpenH264
RUN mkdir -p /opt/build/owt-server/third_party/openh264 && \
    cd /opt/build/owt-server/third_party/openh264 && \
    ln -s -v /usr/local/include/openh264/codec . && \
    ln -s -v /usr/local/lib/libopenh264.so . && \
    echo "const char* stub() {return \"this is a stub lib\";}" > pseudo-openh264.cpp && \
    gcc pseudo-openh264.cpp -fPIC -shared -o pseudo-openh264.so

# Get licode
ARG OWT_LICODE_REPO=https://github.com/lynckia/licode.git
RUN cd /opt/build/owt-server/third_party && \
    git clone ${OWT_LICODE_REPO} && \
    cd licode && \
    git config user.name x && git config user.email x@y && \
    git reset --hard 8b4692c88f1fc24dedad66b4f40b1f3d804b50ca && \
    git am /opt/build/owt-server/scripts/patches/licode/*.patch

# Get webrtc
ARG OWT_WEBRTC_REPO=https://github.com/open-webrtc-toolkit/owt-deps-webrtc.git
RUN mkdir -p /opt/build/owt-server/third_party/webrtc && \
    cd /opt/build/owt-server/third_party/webrtc && \
    git clone -b 59-server ${OWT_WEBRTC_REPO} src && \
    cd src && \
    ./tools-woogeen/install.sh && \
    ./tools-woogeen/build.sh


# Get webrtc79
RUN mkdir -p /opt/build/owt-server/third_party/webrtc-m79 && \
    cd /opt/build/owt-server/third_party/webrtc-m79 && \
    sed -i "s/git clone/git clone --depth 1/" ../../scripts/installWebrtc.sh && \
    bash ../../scripts/installWebrtc.sh


# Get SDK
ARG OWT_SDK_REPO=https://github.com/open-webrtc-toolkit/owt-client-javascript.git
RUN cd /opt/build && \
    git clone -b master ${OWT_SDK_REPO} && \
    cd owt-client-javascript/scripts && \
    git reset --hard v5.0 && \
    npm install && grunt

# Get quic
ARG OWT_QUIC_REPO=https://github.com/open-webrtc-toolkit/owt-deps-quic/releases/download/v0.1/dist.tgz
RUN mkdir -p /opt/build/owt-server/third_party/quic-lib && \
    cd /opt/build/owt-server/third_party/quic-lib && \
    wget -O - ${OWT_QUIC_REPO} | tar xz

# Build and pack owt
RUN cd /opt/build/owt-server && \
    sed -i "/cflags_cc/s/\[/[\"-Wl,rpath=\/usr\/local\/ssl\/lib\",/" source/agent/webrtc/rtcConn/binding.gyp source/agent/webrtc/rtcFrame/binding.gyp && \
    sed -i "s/-lssl/<!@(pkg-config --libs openssl)/" source/agent/webrtc/rtcConn/binding.gyp source/agent/webrtc/rtcFrame/binding.gyp && \
    sed -i "/DENABLE_SVT_HEVC_ENCODER/i\"<!@(pkg-config --cflags SvtHevcEnc)\"," source/agent/video/videoMixer/videoMixer_sw/binding.sw.gyp source/agent/video/videoTranscoder/videoTranscoder_sw/binding.sw.gyp source/agent/video/videoTranscoder/videoAnalyzer_sw/binding.sw.gyp && \
    sed -i "/lSvtHevcEnc/i\"<!@(pkg-config --libs SvtHevcEnc)\"," source/agent/video/videoMixer/videoMixer_sw/binding.sw.gyp source/agent/video/videoTranscoder/videoTranscoder_sw/binding.sw.gyp source/agent/video/videoTranscoder/videoAnalyzer_sw/binding.sw.gyp && \
    sed -i "s/--cflags glib-2.0/--cflags glib-2.0 gstreamer-1.0/" source/agent/analytics/videoGstPipeline/binding.pipeline.gyp && \
    sed -i "/lgstreamer/i\"<!@(pkg-config --libs gstreamer-1.0)\"," source/agent/analytics/videoGstPipeline/binding.pipeline.gyp && \
    sed -i "1i#include <stdint.h>" source/agent/sip/sipIn/sip_gateway/sipua/src/account.c

# Install nan module
RUN cd /opt/build/owt-server && \
    echo {} > package.json && \
    npm install nan

# Build and package
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib:/usr/local/ssl/lib
RUN cd /opt/build/owt-server && \
    ./scripts/build.js -t mcu-all -r -c &&\
    ./scripts/pack.js -t all --install-module --no-pseudo --app-path /opt/build/owt-client-javascript/dist/samples/conference && \
    mkdir -p /opt/dist/home && \
    mv dist /opt/dist/home/owt

 RUN cd /opt/dist/home && \
    echo "#!/bin/bash -e" >>launch.sh && \
    echo "service mongodb start &" >>launch.sh && \
    echo "service rabbitmq-server start &" >>launch.sh && \
    echo "while ! mongo --quiet --eval \"db.adminCommand(\\\"listDatabases\\\")\"" >>launch.sh && \
    echo "do" >>launch.sh && \
    echo "  echo mongod not launch" >>launch.sh && \
    echo "  sleep 1" >>launch.sh && \
    echo "done" >>launch.sh && \
    echo "echo mongodb connected successfully" >>launch.sh && \
    echo "cd /home/owt" >>launch.sh && \
    echo "./management_api/init.sh" >>launch.sh && \
    echo "./bin/start-all.sh" >>launch.sh && \
    chmod +x launch.sh

