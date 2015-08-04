#!/bin/bash
[[ $DEBUG == true ]] && set -x

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_DIR=${PWD}/build
BUILD_OPTIONS=""

[[ -n ${PREFIX} ]] || PREFIX="/etc/nginx"
[[ -n ${USER} ]]   || USER="nginx"
[[ -n ${GROUP} ]]  || GROUP="nginx"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    BUILD_OPTIONS="${BUILD_OPTIONS} --with-file-aio"
elif [[ "$OSTYPE" == "darwin" ]]; then
  echo "hello"
        # Mac OSX
elif [[ "$OSTYPE" == "cygwin" ]]; then
  echo "hello"
        # POSIX compatibility layer and Linux environment emulation for Windows
elif [[ "$OSTYPE" == "msys" ]]; then
  echo "hello"
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
elif [[ "$OSTYPE" == "win32" ]]; then
  echo "hello"
        # I'm not sure this can happen.
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    BUILD_OPTIONS="${BUILD_OPTIONS} --with-file-aio"
else
  echo "hello"
        # Unknown.
fi

function get_and_extract_artifact () {
  local url=$1
  local artifact_dir=$2
  local artifact=$(basename ${url})
  [[ -n ${artifact_dir} ]] || artifact_dir=$(echo ${artifact} | sed 's|\.tar\.gz||g')
  if [[ ! -f ${artifact} ]];then
    echo -n "## Fetching ${url}... " 1>&2
    curl -L -s ${url} -O
    echo "done" 1>&2
  fi

  echo -n "## Extracting artifact ${artifact}... " 1>&2
  [[ -d ${artifact_dir} ]] || mkdir ${artifact_dir}
  tar zxif ${artifact} --strip-components=1 -C ${artifact_dir}
  echo "done" 1>&2

  echo "$(pwd)/${artifact_dir}"
}

function get_pagespeed () {
  local version=1.9.32.6
  local dir=$(get_and_extract_artifact "https://github.com/pagespeed/ngx_pagespeed/archive/v${version}-beta.tar.gz")
  pushd "${dir}" &> /dev/null
  get_and_extract_artifact "https://dl.google.com/dl/page-speed/psol/${version}.tar.gz" "psol" > /dev/null
  popd &> /dev/null

  BUILD_OPTIONS="${BUILD_OPTIONS} --add-module=${dir}"
}

function get_ngx_http_auth_pam_module () {
  local version=1.4
  local dir=$(get_and_extract_artifact "https://github.com/stogh/ngx_http_auth_pam_module/archive/v${version}.tar.gz")

  BUILD_OPTIONS="${BUILD_OPTIONS} --add-module=${dir}"
}

function get_headers_more_nginx_module () {
  local version=0.26
  local dir=$(get_and_extract_artifact "https://github.com/openresty/headers-more-nginx-module/archive/v${version}.tar.gz")

  BUILD_OPTIONS="${BUILD_OPTIONS} --add-module=${dir}"
}

function get_nginx () {
  local version=1.8.0
  local dir=$(get_and_extract_artifact "http://nginx.org/download/nginx-${version}.tar.gz")

  pushd "${dir}" &> /dev/null
}

function get_openssl () {
  local version=1.0.2d
  local dir=$(get_and_extract_artifact "https://www.openssl.org/source/openssl-${version}.tar.gz")

  BUILD_OPTIONS="${BUILD_OPTIONS} --with-openssl=${dir}"
}

function get_zlib () {
  local version=1.2.8
  local dir=$(get_and_extract_artifact "http://zlib.net/zlib-${version}.tar.gz")

  BUILD_OPTIONS="${BUILD_OPTIONS} --with-zlib=${dir}"
}

function get_pcre () {
  local version=8.34
  local dir=$(get_and_extract_artifact "http://downloads.sourceforge.net/project/pcre/pcre/${version}/pcre-${version}.tar.gz")

  BUILD_OPTIONS="${BUILD_OPTIONS} --with-pcre=${dir}"
}

[[ ! -d ${BUILD_DIR} ]] && mkdir ${BUILD_DIR}

cd ${BUILD_DIR}
get_openssl
get_zlib
get_pcre
get_pagespeed
get_ngx_http_auth_pam_module
get_headers_more_nginx_module
get_nginx ## This must be last as we depend on this function to place us in the correct directory for ./configure phase

./configure --prefix="${PREFIX}" \
  --with-cc-opt="-static -static-libgcc" \
  --with-ld-opt="-static" \
  --with-cpu-opt=generic \
  --sbin-path=/usr/sbin/nginx \
  --conf-path="${PREFIX}/nginx.conf" \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=${USER} \
  --group=${GROUP} \
  --with-http_ssl_module \
  --with-http_realip_module \
  --with-http_addition_module \
  --with-http_sub_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_mp4_module \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_random_index_module \
  --with-http_secure_link_module \
  --with-http_stub_status_module \
  --with-http_auth_request_module \
  --with-mail \
  --with-mail_ssl_module \
  --with-ipv6 \
  ${BUILD_OPTIONS} \
  --with-cc-opt=-Wno-error

