
# install psycopg2

## ssh into jupyter pod

```

kubectl get po -n kubeflow-user-example-com
NAME                                                   READY   STATUS    RESTARTS   AGE
pod/ml-pipeline-ui-artifact-846dfccbc-fp872            2/2     Running   0          38h
pod/ml-pipeline-visualizationserver-66fbf97484-tnnbb   2/2     Running   0          38h
pod/test-0                                             2/2     Running   0          60m


kubectl exec -it pod/test-0 -n kubeflow-user-example-com sh

```

## find supported version
```
$ pip debug --verbose | grep cp38
WARNING: This command is only meant for debugging. Do not use this with automation for parsing and getting these details, since the output and options of this command may change without notice.
  cp38-cp38-manylinux_2_17_x86_64
  cp38-abi3-manylinux_2_17_x86_64
  cp38-none-manylinux_2_17_x86_64 

```
## download  from https://pypi.org/project/psycopg2-binary/#files
wget https://files.pythonhosted.org/packages/aa/70/47e1a0bf010ff3d5beb8abe6e57cb764ac950082126ed565c12a54772559/psycopg2_binary-2.9.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl

## upload to the pod and install

```
kubectl cp psycopg2_binary-2.9.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl  kubeflow-user-example-com/test-0:/tmp -c test

kubectl exec -it pod/test-0 -n kubeflow-user-example-com sh

$ cd /tmp
$ ls -al
total 2944
drwxrwxrwt 1 root   root     4096 Nov 19 02:58 .
drwxr-xr-x 1 root   root     4096 Nov 19 02:57 ..
drwx------ 2 root   root     4096 Jun  3 13:40 private-keys-v1.d
-rw-r--r-- 1 jovyan users 2987996 Nov 19 02:58 psycopg2_binary-2.9.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
-rw-r--r-- 1 root   root     3634 Jun  3 13:40 pubring.kbx
-rw------- 1 root   root       32 Jun  3 13:40 pubring.kbx~
-rw------- 1 root   root     1200 Jun  3 13:40 trustdb.gpg
$ pip install psycopg2_binary-2.9.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
Processing ./psycopg2_binary-2.9.2-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
Installing collected packages: psycopg2-binary
Successfully installed psycopg2-binary-2.9.2
```

## test

```
(base) jovyan@test-0:~$ python
Python 3.8.10 | packaged by conda-forge | (default, May 11 2021, 07:01:05) 
[GCC 9.3.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import psycopg2
>>> conn=psycopg2.connect("host=10.40.1.148 port=5432 dbname=test password=id user=pass")
>>> cur.execute("SELECT * FROM test;")
>>> records=cur.fetchall()
>>> 
```
