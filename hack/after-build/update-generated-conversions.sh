#!/bin/bash

# Copyright 2015 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/../..
source "${KUBE_ROOT}/hack/lib/init.sh"

kube::golang::setup_env

genconversion=$(kube::util::find-binary "genconversion")

function generate_version() {
  local group_version=$1
  local TMPFILE="/tmp/conversion_generated.$(date +%s).go"

  echo "Generating for ${group_version}"

  sed 's/YEAR/2015/' hack/boilerplate/boilerplate.go.txt > "$TMPFILE"
  cat >> "$TMPFILE" <<EOF
// DO NOT EDIT. THIS FILE IS AUTO-GENERATED BY \$KUBEROOT/hack/update-generated-conversions.sh

EOF

  "${genconversion}" -v "${group_version}" -f - >>  "$TMPFILE"

  mv "$TMPFILE" "pkg/$(kube::util::group-version-to-pkg-path "${group_version}")/conversion_generated.go"
}

# TODO(lavalamp): get this list by listing the pkg/apis/ directory?
DEFAULT_GROUP_VERSIONS="v1 authorization/v1beta1 autoscaling/v1 batch/v1 extensions/v1beta1 componentconfig/v1alpha1 metrics/v1alpha1 controlplane/v1alpha1"
VERSIONS=${VERSIONS:-$DEFAULT_GROUP_VERSIONS}
for ver in $VERSIONS; do
  # Ensure that the version being processed is registered by setting
  # KUBE_API_VERSIONS.
  KUBE_API_VERSIONS="${ver}" generate_version "${ver}"
done
