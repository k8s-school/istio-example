#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

"$DIR"/istio-install.sh
"$DIR"/bookinfo-install.sh
timeout 5 "$DIR"/bookinfo-query.sh
"$DIR"/port-forward.sh
"$DIR"/istio-uninstall.sh
