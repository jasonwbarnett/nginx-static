#!/bin/bash
[[ $DEBUG == true ]] && set -x

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_DIR=${PWD}/build

function get_and_extract_artifact () {
  local url=$1
  local artifact=$(basename $url)
  if [[ ! -f ${artifact} ]];then
    echo -n "## Fetching ${url}... "
    curl -L -s ${url} -O
    echo "done"
  fi

  echo -n "## Extracting artifact ${artifact}... "
  tar zxif ${artifact}
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

[[ ! -d ${BUILD_DIR} ]] && mkdir ${BUILD_DIR}

cd ${BUILD_DIR}
get_pagespeed
get_ngx_http_auth_pam_module
get_headers_more_nginx_module
get_nginx
get_openssl

