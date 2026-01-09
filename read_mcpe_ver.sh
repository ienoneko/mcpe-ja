#!/bin/bash

set -e
set -o pipefail

if [ $# -ne 1 -o ! -f "$1" ]; then
  echo "Usage: $0 <path to apktool yml>" >&2
  exit 1
fi

yq -r .versionInfo.versionName "$1" | tr '.' '_'
