
# Procedure

## log on to internet facing jumpbox
- docker engine installed
as a root user, go to Dockerfile folder. alternatively you may clone  https://github.com/myminseok/jupyter-scipy-custom-docker.

```
sudo su
cd /home/automation/Documents/tanzu/jupyter-scipy-custom-docker
```
check the file. 
```
root@pcnlpt001:/home/automation/Documents/tanzu/jupyter-scipy-custom-docker# ls -al
total 28
drwxr-xr-x 3 root       root       4096 Nov 26 16:18 .
drwxrwxr-x 4 automation automation 4096 Nov 26 16:39 ..
-rwxr-xr-x 1 root       root        258 Nov 26 16:18 build.sh
-rw-r--r-- 1 root       root       2452 Nov 26 15:56 Dockerfile.kale
-rw-r--r-- 1 root       root       2153 Nov 26 15:56 Dockerfile.mvp1
drwxr-xr-x 8 root       root       4096 Nov 26 15:56 .git
-rw-r--r-- 1 root       root       1597 Nov 26 15:56 README.md

```

edit build.sh and set the right tag. it is important to set different tag from existing tags because the docker image is cached on kubernetes cluster vm and the same tag may not be downloaded with the same tag.  for example `jupyter-scipy-custom:mvp1_v1` to `jupyter-scipy-custom:mvp1_v2`

```
docker build -t jupyter-scipy-custom:mvp1_v1 --file Dockerfile.mvp1 .
docker tag jupyter-scipy-custom:mvp1_v1 platform-harbor.mvp.bsl.local/kubeflow/jupyter-scipy-custom:mvp1_v1

```


run the `build.sh`. it takes sometimes mostly for downloading a new updates from the internet. once downloaded it is cached on local PC. and after built locally, it will tag.
```
root@pcnlpt001:/home/automation/Documents/tanzu/jupyter-scipy-custom-docker# docker images
REPOSITORY                                                         TAG       IMAGE ID       CREATED       SIZE
jupyter-scipy-custom                                               mvp1_v1   106ae8a0463d   4 days ago    8.42GB
platform-harbor.mvp.bsl.local/kubeflow/jupyter-scipy-custom        mvp1_v1   106ae8a0463d   4 days ago    8.42GB
public.ecr.aws/j1r0q0g6/notebooks/notebook-servers/jupyter-scipy   v1.4      93955096f3da   7 weeks ago   1.78GB
```
test
```
docker run -p 8888:8888 jupyter-scipy-custom:mvp1_v1
...
[I 2021-12-01 08:01:47.568 ServerApp] Serving notebooks from local directory: /home/jovyan
[I 2021-12-01 08:01:47.568 ServerApp] Jupyter Server 1.8.0 is running at:
[I 2021-12-01 08:01:47.568 ServerApp] http://0b4ddf6d6d82:8888/lab
[I 2021-12-01 08:01:47.568 ServerApp]     http://127.0.0.1:8888/lab
[I 2021-12-01 08:01:47.568 ServerApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[W 2021-12-01 08:02:23.821 LabApp] Clearing invalid/expired login cookie username-127-0-0-1-8888



```

lets upload to internal docker image repo. 
```
docker push platform-harbor.mvp.bsl.local/kubeflow/jupyter-scipy-custom:mvp1_v1
```

- open https://platform-harbor.mvp.bsl.local with admin/VMware1!
-  goes to projects > kubeflow and search by `jupyter-scipy-custom`
- click on  `jupyter-scipy-custom` and click artifacts tab.
- then you should see 'mvp1_v1' on tags column.
now you uploaded the images successfully.


## update the kubeflow dashboard.
now lets login to TKG bootstrap VM by running following command  with either as `root` or as 'automation' account 
```
ssh root@10.200.159.61
or 
/home/automation/ssh-bootstrap.sh
```
now lets get access to the kubeflow k8s cluster.
```
root@boostrap14:/data/kubeflow-main# tanzu cluster list
  NAME          NAMESPACE  STATUS   CONTROLPLANE  WORKERS  KUBERNETES        ROLES   PLAN  
  tkc-kubeflow  default    running  1/1           5/5      v1.21.2+vmware.1  <none>  dev   

root@boostrap14:/data/kubeflow-main# tanzu cluster kubeconfig get tkc-kubeflow --admin
Credentials of cluster 'tkc-kubeflow' have been saved 
You can now access the cluster by running 'kubectl config use-context tkc-kubeflow-admin@tkc-kubeflow'


root@boostrap14:/data/kubeflow-main# k config use-context tkc-kubeflow-admin@tkc-kubeflow
Switched to context "tkc-kubeflow-admin@tkc-kubeflow".

root@boostrap14:/data/kubeflow-main# k config get-contexts
CURRENT   NAME                              CLUSTER        AUTHINFO             NAMESPACE
*         tkc-kubeflow-admin@tkc-kubeflow   tkc-kubeflow   tkc-kubeflow-admin   
          tkg-mgmt-admin@tkg-mgmt           tkg-mgmt       tkg-mgmt-admin       

root@boostrap14:/data/kubeflow-main# k get nodes
NAME                                 STATUS   ROLES                  AGE   VERSION
tkc-kubeflow-control-plane-rk2pw     Ready    control-plane,master   13d   v1.21.2+vmware.1
tkc-kubeflow-md-0-587f485c7d-4wxqq   Ready    <none>                 13d   v1.21.2+vmware.1
tkc-kubeflow-md-0-587f485c7d-6xb7f   Ready    <none>                 12d   v1.21.2+vmware.1
tkc-kubeflow-md-0-587f485c7d-qx5lv   Ready    <none>                 13d   v1.21.2+vmware.1
tkc-kubeflow-md-0-587f485c7d-s7qpm   Ready    <none>                 13d   v1.21.2+vmware.1
tkc-kubeflow-md-0-587f485c7d-wp2mw   Ready    <none>                 12d   v1.21.2+vmware.1
```
lets verify there is kubeflow installation. you should see 'istio-system', and 'kubeflow' namespaces
```
root@boostrap14:/data/kubeflow-main# k get ns
NAME                        STATUS   AGE
auth                        Active   5d22h
avi-system                  Active   13d
cert-manager                Active   5d22h
default                     Active   13d
istio-system                Active   5d22h.              
knative-eventing            Active   5d22h
knative-serving             Active   5d22h
kube-node-lease             Active   13d
kube-public                 Active   13d
kube-system                 Active   13d
kubeflow                    Active   5d22h
kubeflow-user-example-com   Active   5d22h
tanzu-package-repo-global   Active   13d
tanzu-system-dashboards     Active   12d
tanzu-system-monitoring     Active   12d
tkg-extensions              Active   12d
tkg-system                  Active   13d
tkg-system-public           Active   13d

```
lets check the AVI loadbalancer is assigined and pod is running. 
```
root@boostrap14:/data/kubeflow-main# k get all -n istio-system

NAME                                         READY   STATUS    RESTARTS   AGE
pod/authservice-0                            1/1     Running   0          5d22h
pod/cluster-local-gateway-749f9bf849-wfrxm   1/1     Running   1          5d22h
pod/istio-ingressgateway-65fb4679c4-vbbhr    1/1     Running   1          5d22h
pod/istiod-857f64b7cf-t9wvn                  1/1     Running   1          5d22h

NAME                            TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                                                      AGE
service/authservice             ClusterIP      100.64.52.248    <none>          8080/TCP                                                                     5d22h
service/cluster-local-gateway   ClusterIP      100.69.162.115   <none>          15020/TCP,80/TCP                                                             5d22h
service/istio-ingressgateway    LoadBalancer   100.67.64.209    10.200.159.52   15021:31487/TCP,80:30621/TCP,443:30490/TCP,31400:31021/TCP,15443:31947/TCP   5d22h
service/istiod                  ClusterIP      100.69.40.205    <none>          15010/TCP,15012/TCP,443/TCP,15014/TCP                                        5d22h
service/knative-local-gateway   ClusterIP      100.64.42.127    <none>          80/TCP                                                                       5d22h

NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/cluster-local-gateway   1/1     1            1           5d22h
deployment.apps/istio-ingressgateway    1/1     1            1           5d22h
deployment.apps/istiod                  1/1     1            1           5d22h

NAME                                               DESIRED   CURRENT   READY   AGE
replicaset.apps/cluster-local-gateway-749f9bf849   1         1         1       5d22h
replicaset.apps/istio-ingressgateway-65fb4679c4    1         1         1       5d22h
replicaset.apps/istiod-857f64b7cf                  1         1         1       5d22h

NAME                           READY   AGE
statefulset.apps/authservice   1/1     5d22h

```


goes to kubeflow directory.
```
root@boostrap14:~# cd /data/kubeflow-main/
root@boostrap14:/data/kubeflow-main#
```

vi  61_apps_jupyter_istio.yml and add the new image.
```
220     spawnerFormDefaults:
221       image:
222         # The container Image for the user's Jupyter Notebook
223         value: platform-harbor.mvp.bsl.local/kubeflow/jupyter-scipy-custom:mvp1_v1
224         # The list of available standard container Images
225         options:
226         - platform-harbor.mvp.bsl.local/kubeflow/jupyter-scipy-custom:mvp1_v1
227         - platform-harbor.mvp.bsl.local/kubeflow/j1r0q0g6/notebooks/notebook-servers/jupyter-scipy:v1.4
228         - platform-harbor.mvp.bsl.local/kubeflow/j1r0q0g6/notebooks/notebook-servers/jupyter-pytorch-full:v1.4
229         - platform-harbor.mvp.bsl.local/kubeflow/j1r0q0g6/notebooks/notebook-servers/jupyter-pytorch-cuda-full:v1.4
230         - platform-harbor.mvp.bsl.local/kubeflow/j1r0q0g6/notebooks/notebook-servers/jupyter-tensorflow-full:v1.4
231         - platform-harbor.mvp.bsl.local/kubeflow/j1r0q0g6/notebooks/notebook-servers/jupyter-tensorflow-cuda-full:v1.4
232       imageGroupOne:

```
now apply to k8s 
```
k apply -f 61_apps_jupyter_istio.yml
```

- in 1-3 minutes, access https://kubeflow.mvp.bsl.local/_/jupyter/?ns=kubeflow-user-example-com with webbrowser, 
- login user@example.com / 12341234
- goes to Nodebooks and click "New Notebooks" and you will see new docker images and tags on the list.
