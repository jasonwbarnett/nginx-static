#!/bin/bash

PWD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
BUILD_DIR=${PWD}/build

function get_pagespeed () {
  local version=1.9.32.6
  wget "https://github.com/pagespeed/ngx_pagespeed/archive/v${version}-beta.tar.gz"
  tar zxf v${version}-beta.tar.gz
  pushd ngx_pagespeed-${version}-beta
  wget https://dl.google.com/dl/page-speed/psol/${version}.tar.gz
  tar xzf ${version}.tar.gz  # extracts to psol/
  # => ngx_pagespeed-${version}-beta
  popd
}

function get_ngx_http_auth_pam_module () {
  local version=1.4
  wget "https://github.com/stogh/ngx_http_auth_pam_module/archive/v${version}.tar.gz"
  tar zxf v${version}.tar.gz
  # => ngx_http_auth_pam_module-${version}
}

function get_headers_more_nginx_module () {
  local version=0.26
  wget "https://github.com/openresty/headers-more-nginx-module/archive/v${version}.tar.gz"
  tar zxf v${version}.tar.gz
  # => headers-more-nginx-module-${version}
}

[[ ! -d ${BUILD_DIR} ]] && mkdir ${BUILD_DIR}

cd ${BUILD_DIR}
get_pagespeed
get_ngx_http_auth_pam_module
get_headers_more_nginx_module
