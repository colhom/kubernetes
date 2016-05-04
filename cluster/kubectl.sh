#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
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

# Stop the bleeding, turn off the warning until we fix token gen.
# echo "-=-=-=-=-=-=-=-=-=-="
# echo "NOTE:"
# echo "kubectl.sh is deprecated and will be removed soon."
# echo "please replace all usage with calls to the kubectl"
# echo "binary and ensure that it is in your PATH." 
# echo ""
# echo "Please see 'kubectl help config' for more details"
# echo "about configuring kubectl for your cluster."
# echo "-=-=-=-=-=-=-=-=-=-="


KUBE_ROOT=${KUBE_ROOT:-$(dirname "${BASH_SOURCE}")/..}
source "${KUBE_ROOT}/cluster/kube-util.sh"

# Get the absolute path of the directory component of a file, i.e. the
# absolute path of the dirname of $1.
get_absolute_dirname() {
  echo "$(cd "$(dirname "$1")" && pwd)"
}

find-kubectl-binary

if [[ "$KUBERNETES_PROVIDER" == "gke" ]]; then
  detect-project &> /dev/null
elif [[ "$KUBERNETES_PROVIDER" == "ubuntu" ]]; then
  detect-master > /dev/null
  config=(
    "--server=http://${KUBE_MASTER_IP}:8080"
  )
fi

if false; then
  # disable these debugging messages by default
  echo "current-context: \"$(${kubectl} "${config[@]:+${config[@]}}" config view -o template --template='{{index . "current-context"}}')\"" >&2
  echo "Running:" "${kubectl}" "${config[@]:+${config[@]}}" "${@+$@}" >&2
fi

"${kubectl}" "${config[@]:+${config[@]}}" "${@+$@}"
