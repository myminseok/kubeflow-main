# kubeflow-main

### kubeflow capacity
Recommend
```
* 16GB memory
* 6 cpu
* 45G disk space
```
TKGm worker node: medium * 3

- https://opendatahub.io/docs/kubeflow/installation.html


# installation 
- installation guide: https://www.kubeflow.org/docs/started/installing-kubeflow/
- all in one installation: https://github.com/kubeflow/manifests#installation

## installing internet restricted env
reference https://github.com/kubeflow/kubeflow/issues/5061
- 1. Run the kfctl build command and edit them from the kustomize folder generated
- 2. Clone the Kubeflow manifests ( https://github.com/kubeflow/manifests.git) and edit the image paths, then change your deployment yaml to point to your manifests instead

## procedure
### generate deployment manifests
run ./generate-kubeflow-deploy-from-manifests.sh. it will create deployment ymls under `./generated-deploy` folder.

### download images
vi no-internet-env.sh
```
export TKG_IMAGES_DOWNLOAD_FOLDER="/data/kubeflow-images"
export TKG_CUSTOM_IMAGE_REPOSITORY="infra-harbor.lab.pcfdemo.net/kubeflow"
export TKG_CUSTOM_IMAGE_REPOSITORY_CA_CERTIFICATE="LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUR1VENDQXFHZ0F3SUJBZ0lVQlJiTnM0bSs2UVZSdWEzS2ZqZHo3TzhDS3d3d0RRWUpLb1pJaHZjTkFRRUwKQlFBd09qRUxNQWtHQTFVRUJoTUNTMUl4RFRBTEJnTlZCQW9NQkUxNVEwRXhIREFhQmdOVkJBTU1FM0p2YjNRZwpVMlZzWmlCVGFXZHVaV1FnUTBFd0hoY05NakV4TURJeU1USXdPVEF6V2hjTk16RXhNREl3TVRJd09UQXpXakJECk1Rc3dDUVlEVlFRR0V3SkxVakVPTUF3R0ExVUVDZ3dGVFhsUGNtY3hEakFNQmdOVkJBc01CVTE1VDNKbk1SUXcKRWdZRFZRUUREQXR3WTJaa1pXMXZMbTVsZERDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQwpnZ0VCQUtvQTRnT1EySHFobVcvaGhZZjRXTUJrcUMvV3dzcVRVRVQvakxSZjkxa2VsSk5zY2UwYnFNeTlWLzdDCnJNRG5BcHIxUnloYzg3anhjbURtUGtFblNDcjg3cnc4eXdhWElnWDJjVGMxNitBZmJqTG5sK0ZJR3NldFlrOGIKMVgrTjJGTEMvNzd4RmJUVEdLYzE4aVYrSmFxd0Vta2JCWDAwNDJHZkI5Q3ZiYUtvajRwTlFqY2puOFN1akdSaAo3VmpBcEpzUEwySU5jM3RYc3l4cVBoZWNwUE5GWXU4ZEVuOFVidjRmbU9lNVB5NFRoWkY4cERIcXJwUFBqQnhmCjhRSlk4cCtXa2NZZWFRaGJKMGZsc3VNVGhMVTVEaTN3d3ZDNnBia1ZTZk02OE5KOXR3Q3dWZVlIRzljTTJZYnAKMlUwWElZVEtkZjd6T29NZ2RJdVdGZUFOeHFFQ0F3RUFBYU9CclRDQnFqQUpCZ05WSFJNRUFqQUFNQjBHQTFVZApEZ1FXQkJTbUtYcXJYbnB1WVl2NHkvTlFQTnZIN1JLN0JUQUxCZ05WSFE4RUJBTUNCYUF3SFFZRFZSMGxCQll3CkZBWUlLd1lCQlFVSEF3RUdDQ3NHQVFVRkJ3TUNNRklHQTFVZEVRUkxNRW1DQ2lvdWRHVnpkQzVqYjIyQ0VTb3UKYkdGaUxuQmpabVJsYlc4dWJtVjBnaHhwYm1aeVlTMW9ZWEppYjNJdWJHRmlMbkJqWm1SbGJXOHVibVYwaHdSLwpBQUFCaHdUQXFBQUZNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJpZTAwR0VpQ2M1c1BreVl3N0hReFV1cjFvClBVbGFTb3c3d080YW10ODNOYzJDQ0VLQVlIdExqVXZ6eTBiMStBWXVyTE1wVFRkVVE0VmQwb3ZpUGJ1Y2tYdXgKOXM4NlJyNW9jdzVpUzQ0TmtLRTU5SVhwUmQyOWdnUG5UcUZaKzVhcHNqY2xoaEhVL0ZEOVJQcWxNeUxrNXZsTQplTENXSjNDVExibzlOZllkZGdHNG9JcmFsSVpsK2lJQ2hZMHcvWDJIZVBVbFJaY0xEdTU4MVhqeFpWQnc2VmNNCnN4UDVqWU9qVm1qRmJNRXFWNjhDN25vV1REUTBZUWphQk9rdG9kOFQzbzVabFowV2tqYjZIa2dBdkQxbnNSbTMKQ2drZVlXZW44OEpKUU94V1djaEtqMUZCc3pkVkN4aEZBWEtoUUUwZWVXcG5lbVdWazZDWllNUy8zWUdrCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
## define source file folder to work
export SOURCE_DEPLOY_FOLDER="../generated-deploy"
## kubeflow uses docker image with various format, different style.
## to include as much images list as possible, extract container image repo list from kubeflow deployment scripts.
## this list will be used to generate download/upload images script and convert-generated-deploy-with-local-image-repo.sh
export EXTRACTED_IMAGE_REPO_FILE="extracted-image-repo-list-from-deploy"
## define image url to skip from download, upload script.
## - <image-repository-context>
## - <image-registry-domain>/<image-registry-context>
export EXCLUDE_IMAGE_CONTEXTS=("value" "#" "Look" "for" "specific" "tags" "for" "each" "image" \
	"istio" \
	"tritonserver" \
  "seldonio/mlserver" \
	"ml-pipeline/frontend" \
	"ml-pipeline/visualization-server" \
	"nvidia/tritonserver" \
	"google-containers/busybox")
```

generate scripts.

```
cd publish-kubeflow-images
./gen-scripts.sh
```

generated files
```
download-images.sh
upload-images.sh
cacrtbase64d.crt
```

download images under the folder from variable TKG_IMAGES_DOWNLOAD_FOLDER="/data/kubeflow-images"
```
./download-images.sh
```

### upload images to harbor repo on Internet restricted env.
upload images under the folder from variable TKG_IMAGES_DOWNLOAD_FOLDER="/data/kubeflow-images" 
```
./upload-images.sh
```

### convert deployment yaml to points to local repo.
following scripts will convert deployment scripts from SOURCE_DEPLOY_FOLDER="../generated-deploy" to CONVERTED_FOLDER="../converted-deploy" one by one.
```
./convert-generated-deploy-with-local-image-repo.sh
./convert-poststep.sh
```

### deploy kubeflow.
- 3 VIPs for kubeflow service type loadbalancer. (1 for VIP, 2 for Service Engine VM) 
- 2 internal IPs for SE VM (routable to kubernetes worknode VM)
- TLS certificate for kubeflow domain. (ie, kubeflow.mvp.bsl.local)

#### converted-deploy/23_common_istion-install.yml
change istio-ingressgateway to service type LoadBalancer
```
1383   selector:
1384     app: istio-ingressgateway
1385     istio: ingressgateway
1386   type: LoadBalancer
...
```

####  converted-deploy/38_common_kubeflow-istio-resources.yml
add lines from 68 - 79 for Upgrade HTTP to HTTPS
```
 52 ---
 53 apiVersion: networking.istio.io/v1alpha3
 54 kind: Gateway
 55 metadata:
 56   name: kubeflow-gateway
 57   namespace: kubeflow
 58 spec:
 59   selector:
 60     istio: ingressgateway
 61   servers:
 62   - hosts:
 63     - '*'
 64     port:
 65       name: http
 66       number: 80
 67       protocol: HTTP
 68 # Upgrade HTTP to HTTPS
 69     tls:
 70       httpsRedirect: true
 71   - hosts:
 72     - "*"
 73     port:
 74       name: https
 75       number: 443
 76       protocol: HTTPS
 77     tls:
 78       mode: SIMPLE
 79       credentialName: kubeflow-tls

```

#### cert-manager
you can use cert-manager included in kubeflow, but tkg-extension also uses cert-manager. and if you delete kubeflow, it may delete cert-manager by mistake. then it may break tkg-extension too. we recommend to use cert-manager from tkg-extension. so lets  delete converted-deploy/11_common_cert-manager.yml.

```
tanzu package install cert-manager --package-name cert-manager.tanzu.vmware.com --namespace tkg-extensions --version 1.1.0+vmware.1-tkg.2 --create-namespace

kubectl get app -A

tanzu package installed list -A
```
https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid/1.4/vmware-tanzu-kubernetes-grid-14/GUID-packages-cert-manager.html


### generate kubeflow domain certificate
```
cd /data/kubeflow-main/generate-self-signed-cert
edit openssl-domain.conf

[ alt_names ]
DNS.1 = kubeflow.mvp.bsl.local
IP.1 = 127.0.0.1
IP.2 = 10.200.159.52
```
run ./generate.sh

cat create-secret-tls.sh 
```
kubectl create ns kubeflow-tls
kubectl delete secret  kubeflow-tls -n istio-system
kubectl delete secret  kubeflow-tls -n kubeflow -n kubeflow
kubectl create secret tls kubeflow-tls --cert=./domain.crt --key=./domain.key  -n istio-system
kubectl create secret tls kubeflow-tls --cert=./domain.crt --key=./domain.key  -n kubeflow
```
run create-secret-tls.sh 


### deploy kubeflow
you may run following command 2 or 3 times until there is no error.
```
kubectl apply -f converted-deploy/
```
AVI virtual service should be assigned. otherwise go to troubleshooting section below
```
kubectl get all -n istio-system

NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                                                      AGE
service/authservice             ClusterIP      100.64.52.248    <none>          8080/TCP                                                                     4h38m
service/cluster-local-gateway   ClusterIP      100.69.162.115   <none>          15020/TCP,80/TCP                                                             4h38m
service/istio-ingressgateway    LoadBalancer   100.67.64.209    10.200.159.52   15021:31487/TCP,80:30621/TCP,443:30490/TCP,31400:31021/TCP,15443:31947/TCP   4h38m
service/istiod                  ClusterIP      100.69.40.205    <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP                                        4h38m
service/knative-local-gateway   ClusterIP      100.64.42.127    <none>          80/TCP   
```
check pod status
```
watch kubectl get po --field-selector=status.phase!=Running -A
```

### Troubleshooting

#### AVI virtual service is not assigned, 'pending'
this will be impreved on next AVI version (higher than 20.1.6)
```
kubectl get svc -n istio-system

NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                                                      AGE
service/authservice             ClusterIP      100.64.52.248    <none>          8080/TCP                                                                     4h38m
service/cluster-local-gateway   ClusterIP      100.69.162.115   <none>          15020/TCP,80/TCP                                                             4h38m
service/istio-ingressgateway    LoadBalancer   100.67.64.209    pending        15021:31487/TCP,80:30621/TCP,443:30490/TCP,31400:31021/TCP,15443:31947/TCP   4h38m
service/istiod                  ClusterIP      100.69.40.205    <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP                                        4h38m
service/knative-local-gateway   ClusterIP      100.64.42.127    <none>          80/TCP   
```

if you delete an ingress or service type Loadbalancer on kubernetes  and redeploy it, you may see the loadbalancer IP is pending  state. and even  no virtual service is created on AVI dashboard.  it happens when you delete ingress, it doesn't delete object on AVI cleanly,  especially  `pool`.  and you cannot delete  the pool on AVI dashboard but complains it is referenced by another object 'l4policyset'. in this case, you need to delete the referencing object manually via AVI controller VM.

```
ssh admin@AVI_CONTROLLER_VM

admin@10-30-1-10:~$ 
admin@10-30-1-10:~$ shell
Login: admin
Password:

[admin:10-30-1-10]: > show l4policyset
+---------------------------------------------------------+--------------------------------------------------+
| Name                                                    | UUID                                             |
+---------------------------------------------------------+--------------------------------------------------+ 
| default-tkc-kubeflow--istio-system-istio-ingressgateway | l4policyset-bf2e3704-6563-4666-b007-ef1fd75d3f9e |
+---------------------------------------------------------+--------------------------------------------------+
[admin:10-30-1-10]: > 
[admin:10-30-1-10]: > delete l4policyset default-tkc-kubeflow--istio-system-istio-ingressgateway
Successfully deleted default-tkc-kubeflow--istio-system-istio-ingressgateway.
```

go back to AVI UI, and delete virtual service and related objects. delete the pool. now you can delete and redeploy ingress object on kubernetes.

### looping to delete notebooks 
```
kubectl get notebooks -A

kubectl delete notebook <NAME> -n kubeflow-user-example-com
```
ref https://www.kubeflow.org/docs/components/notebooks/troubleshooting/
