/*
Copyright 2015 The Kubernetes Authors All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package e2e

import (
	"fmt"

	. "github.com/onsi/ginkgo"
	federationapi "k8s.io/kubernetes/federation/apis/federation"
	"k8s.io/kubernetes/pkg/api"
	"k8s.io/kubernetes/test/e2e/framework"
)

// Create/delete cluster api objects
var _ = framework.KubeDescribe("Federated api-server [Feature:Federation]", func() {
	f := framework.NewDefaultFederatedFramework("federated-cluster")
	It("should allow creation of cluster api objects", func() {
		cluster := federationapi.Cluster{
			ObjectMeta: api.ObjectMeta{
				Name: "e2e-test-cluster",
			},
			Spec: federationapi.ClusterSpec{
				ServerAddressByClientCIDRs: []federationapi.ServerAddressByClientCIDR{
					{
						ClientCIDR:    "10.0.0.0/16",
						ServerAddress: "10.0.1.2",
					},
				},
				Credential: "0xDEADBEEF",
			},
		}
		_, err := f.FederatedClient.Clusters().Create(&cluster)
		framework.ExpectNoError(err, fmt.Sprintf("creating cluster: %+v", err))
		_, err = f.FederatedClient.Clusters().Get(cluster.ObjectMeta.Name)
		framework.ExpectNoError(err, fmt.Sprintf("get cluster: %+v", err))
	})
})
