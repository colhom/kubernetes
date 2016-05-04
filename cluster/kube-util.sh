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

# This script contains skeletons of helper functions that each provider hosting
# Kubernetes must implement to use cluster/kube-*.sh scripts.
# It sets KUBERNETES_PROVIDER to its default value (gce) if it is unset, and
# then sources cluster/${KUBERNETES_PROVIDER}/util.sh.

KUBERNETES_PROVIDER="${KUBERNETES_PROVIDER:-gce}"

# Must ensure that the following ENV vars are set
function detect-master {
	echo "KUBE_MASTER_IP: $KUBE_MASTER_IP" 1>&2
	echo "KUBE_MASTER: $KUBE_MASTER" 1>&2
}

# Get node names if they are not static.
function detect-node-names {
	echo "NODE_NAMES: [${NODE_NAMES[*]}]" 1>&2
}

# Get node IP addresses and store in KUBE_NODE_IP_ADDRESSES[]
function detect-nodes {
	echo "KUBE_NODE_IP_ADDRESSES: [${KUBE_NODE_IP_ADDRESSES[*]}]" 1>&2
}

# Verify prereqs on host machine
function verify-prereqs {
	echo "TODO: verify-prereqs" 1>&2
}

# Validate a kubernetes cluster
function validate-cluster {
	# by default call the generic validate-cluster.sh script, customizable by
	# any cluster provider if this does not fit.
	"${KUBE_ROOT}/cluster/validate-cluster.sh"
}

# Instantiate a kubernetes cluster
function kube-up {
	echo "TODO: kube-up" 1>&2
}

# Delete a kubernetes cluster
function kube-down {
	echo "TODO: kube-down" 1>&2
}

# Update a kubernetes cluster
function kube-push {
	echo "TODO: kube-push" 1>&2
}

# Prepare update a kubernetes component
function prepare-push {
	echo "TODO: prepare-push" 1>&2
}

# Update a kubernetes master
function push-master {
	echo "TODO: push-master" 1>&2
}

# Update a kubernetes node
function push-node {
	echo "TODO: push-node" 1>&2
}

# Execute prior to running tests to build a release if required for env
function test-build-release {
	echo "TODO: test-build-release" 1>&2
}

# Execute prior to running tests to initialize required structure
function test-setup {
	echo "TODO: test-setup" 1>&2
}

# Execute after running tests to perform any required clean-up
function test-teardown {
	echo "TODO: test-teardown" 1>&2
}

function find-kubectl-binary {
    # Detect the OS name/arch so that we can find our binary
    case "$(uname -s)" in
	Darwin)
	    host_os=darwin
	    ;;
	Linux)
	    host_os=linux
	    ;;
	*)
	    echo "Unsupported host OS.  Must be Linux or Mac OS X." >&2
	    exit 1
	    ;;
    esac

    case "$(uname -m)" in
	x86_64*)
	    host_arch=amd64
	    ;;
	i?86_64*)
	    host_arch=amd64
	    ;;
	amd64*)
	    host_arch=amd64
	    ;;
	arm*)
	    host_arch=arm
	    ;;
	i?86*)
	    host_arch=386
	    ;;
	s390x*)
	    host_arch=s390x
	    ;;
	ppc64le*)
	    host_arch=ppc64le
	    ;;
	*)
	    echo "Unsupported host arch. Must be x86_64, 386, arm, s390x or ppc64le." >&2
	    exit 1
	    ;;
    esac

    # If KUBECTL_PATH isn't set, gather up the list of likely places and use ls
    # to find the latest one.
    if [[ -z "${KUBECTL_PATH:-}" ]]; then
	locations=(
	    "${KUBE_ROOT}/_output/dockerized/bin/${host_os}/${host_arch}/kubectl"
	    "${KUBE_ROOT}/_output/local/bin/${host_os}/${host_arch}/kubectl"
	    "${KUBE_ROOT}/platforms/${host_os}/${host_arch}/kubectl"
	)
	kubectl=$( (ls -t "${locations[@]}" 2>/dev/null || true) | head -1 )

	if [[ ! -x "$kubectl" ]]; then
	    {
		echo "It looks as if you don't have a compiled kubectl binary"
		echo
		echo "If you are running from a clone of the git repo, please run"
		echo "'./build/run.sh hack/build-cross.sh'. Note that this requires having"
		echo "Docker installed."
		echo
		echo "If you are running from a binary release tarball, something is wrong. "
		echo "Look at http://kubernetes.io/ for information on how to contact the "
		echo "development team for help."
	    } >&2
	    exit 1
	fi
    elif [[ ! -x "${KUBECTL_PATH}" ]]; then
	{
	    echo "KUBECTL_PATH environment variable set to '${KUBECTL_PATH}', but "
	    echo "this doesn't seem to be a valid executable."
	} >&2
	exit 1
    fi
    kubectl="${KUBECTL_PATH:-${kubectl}}"
}

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/..
PROVIDER_UTILS="${KUBE_ROOT}/cluster/${KUBERNETES_PROVIDER}/util.sh"
if [ -f ${PROVIDER_UTILS} ]; then
    source "${PROVIDER_UTILS}"
fi
