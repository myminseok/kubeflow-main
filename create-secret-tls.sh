## cat generate-self-signed-cert/openssl-domain.conf
#[ alt_names ]
#DNS.1 = kubeflow.mvp.bsl.local
#IP.1   = 127.0.0.1
#IP.3 = 10.200.159.52


kubectl create secret tls kubeflow-tls --cert=./generate-self-signed-cert/domain.crt --key=./generate-self-signed-cert//domain.key  -n istio-system
kubectl create secret tls kubeflow-tls --cert=./generate-self-signed-cert//domain.crt --key=./generate-self-signed-cert/domain.key  -n kubeflow
