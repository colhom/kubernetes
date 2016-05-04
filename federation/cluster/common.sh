
source "${KUBE_ROOT}/cluster/common.sh"

export FEDERATED_APISERVER_DEPLOYMENT_NAME='federated-apiserver'
export FEDERATED_APISERVER_IMAGE_REPO='gcr.io/google_containers/federated-apiserver'
export FEDERATED_APISERVER_IMAGE_TAG="`cat ${KUBE_ROOT}/_output/release-stage/server/linux-amd64/kubernetes/server/bin/federated-apiserver.docker_tag`"
export FEDERATED_SERVICE_CIDR=${FEDERATED_SERVICE_CIDR:-"10.10.0.0/24"}

#Only used for providers that require a nodeport service (vagrant for now)
#We will use loadbalancer services where we can
export FEDERATED_API_NODEPORT=32111

template="go run ${KUBE_ROOT}/federation/cluster/template.go"

#TODO(colhom): due to the way "context name" <--> "provider" mapping is not exposed, we're going to have to
#do a switch(KUBERNETES_PROVIDER) and do the mapping here. Vagrant happens to work like this, but this won't
#work for gce (for instance)
host_kubectl="${KUBE_ROOT}/cluster/kubectl.sh --context=${KUBERNETES_PROVIDER} --namespace=federation-e2e"

FEDERATION_KUBECONFIG_PATH="${KUBE_ROOT}/federation/cluster/kubeconfig"
federation_kubectl="${KUBE_ROOT}/cluster/kubectl.sh --context=federated-cluster --namespace=default"

export FEDERATED_API_TOKEN=""

function push-resources {

    manifests_root="${KUBE_ROOT}/federation/manifests/"

    $host_kubectl apply -f "${manifests_root}/federation-ns.yaml"
    $host_kubectl delete pods,svc,rc,deployment,secret -lapp=federated-e2e

    FEDERATED_API_HOST=""
    if [[ "$KUBERNETES_PROVIDER" == "vagrant" ]];then
	node_addresses=`$host_kubectl get nodes -o=jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'`
	FEDERATED_API_HOST=`printf "$node_addresses" | cut -d " " -f1`
    else
	echo "$KUBERNETES_PROVIDER is not (yet) supported for e2e testing"
	exit 1
    fi
    export FEDERATED_API_HOST

    FEDERATED_API_TOKEN="$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)"
    export FEDERATED_API_KNOWN_TOKENS="${FEDERATED_API_TOKEN},admin,admin"

    $template "${manifests_root}/federated-apiserver-"{deployment,service,secrets}".yaml" | $host_kubectl create -f -

    CONTEXT=federated-cluster \
	   KUBE_BEARER_TOKEN="$FEDERATED_API_TOKEN" \
	   KUBE_MASTER_IP="${FEDERATED_API_HOST}:${FEDERATED_API_NODEPORT}" \
	   SECONDARY_KUBECONFIG=true \
	   create-kubeconfig
}
