#!/bin/bash
[[ $DEBUG == true ]] && set -x

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_DIR=${PWD}/build

function get_and_extract_artifact () {
  local url=$1
  local artifact=$(basename ${url})
  local artifact_dir=$(echo ${artifact} | sed 's|\.tar\.gz||g')
  if [[ ! -f ${artifact} ]];then
    echo -n "## Fetching ${url}... "
    curl -L -s ${url} -O
    echo "done"
  fi

  echo -n "## Extracting artifact ${artifact}... "
  [[ -d ${artifact_dir} ]] || mkdir ${artifact_dir}
  tar zxif ${artifact} --strip-components=1 -C ${artifact_dir}
  echo "done"
}

function get_pagespeed () {
  local version=1.9.32.6
  get_and_extract_artifact "https://github.com/pagespeed/ngx_pagespeed/archive/v${version}-beta.tar.gz"
  pushd ngx_pagespeed-${version}-beta &> /dev/null
  get_and_extract_artifact https://dl.google.com/dl/page-speed/psol/${version}.tar.gz
  # => ngx_pagespeed-${version}-beta
  popd &> /dev/null
}

function get_ngx_http_auth_pam_module () {
  local version=1.4
  get_and_extract_artifact "https://github.com/stogh/ngx_http_auth_pam_module/archive/v${version}.tar.gz"
  # => ngx_http_auth_pam_module-${version}
}

function get_headers_more_nginx_module () {
  local version=0.26
  get_and_extract_artifact "https://github.com/openresty/headers-more-nginx-module/archive/v${version}.tar.gz"
  # => headers-more-nginx-module-${version}
}

function get_nginx () {
  local version=1.8.0
  get_and_extract_artifact "http://nginx.org/download/nginx-${version}.tar.gz"
}

function get_openssl () {
  local version=1.0.2d
  get_and_extract_artifact "https://www.openssl.org/source/openssl-${version}.tar.gz"
}

function get_zlib () {
  local version=1.2.8
  get_and_extract_artifact "http://zlib.net/zlib-${version}.tar.gz"
}

function get_pcre () {
  local version=8.34
  get_and_extract_artifact "http://downloads.sourceforge.net/project/pcre/pcre/${version}/pcre-${version}.tar.gz"
}

[[ ! -d ${BUILD_DIR} ]] && mkdir ${BUILD_DIR}

cd ${BUILD_DIR}
get_pagespeed
get_ngx_http_auth_pam_module
get_headers_more_nginx_module
get_zlib
get_pcre
get_nginx
get_openssl

./configure --prefix=/etc/nginx \
  --with-cc-opt="-static -static-libgcc" \
  --with-ld-opt="-static" \
  --with-cpu-opt=generic \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log \
  --pid-path=/var/run/nginx.pid \
  --lock-path=/var/run/nginx.lock \
  --http-client-body-temp-path=/var/cache/nginx/client_temp \
  --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
  --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
  --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
  --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
  --user=nginx \
  --group=nginx \
  --with-openssl='/home/jbarnett/nginx-compile/openssl-1.0.2d' \
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
  --with-file-aio \
  --with-ipv6 \
  --with-cc-opt=-Wno-error
