#!/bin/bash

OUTPUT_FOLDER="./generated-deploy"
SOURCE_MANIFEST_FOLDER="./kubeflow-manifests-v1.4.0/"
mkdir -p $OUTPUT_FOLDER
##while ! kustomize build $SOURCE_MANIFEST_FOLDER/example | tee file.yml; do echo "Retrying to apply resources"; sleep 10; done
kustomize build $SOURCE_MANIFEST_FOLDER/example > kubeflow-all-in-one.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/cert-manager/cert-manager/base > $OUTPUT_FOLDER/11_common_cert-manager.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/cert-manager/kubeflow-issuer/base > $OUTPUT_FOLDER/12_common_kubeflow-issuer.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/istio-1-9/istio-crds/base > $OUTPUT_FOLDER/21_common_istio-crts.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/istio-1-9/istio-namespace/base > $OUTPUT_FOLDER/22_common_istio-namespace.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/istio-1-9/istio-install/base > $OUTPUT_FOLDER/23_common_istio-install.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/dex/overlays/istio > $OUTPUT_FOLDER/31_common_dex-overlays-istio.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/oidc-authservice/base > $OUTPUT_FOLDER/32_common_oidc-authservice.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/knative/knative-serving/base > $OUTPUT_FOLDER/33_common_knative-serving.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/knative/knative-eventing/base > $OUTPUT_FOLDER/35_common_knative-eventing.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/istio-1-9/cluster-local-gateway/base > $OUTPUT_FOLDER/34_common_istio-cluster-local-gateway.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/kubeflow-namespace/base > $OUTPUT_FOLDER/36_common_kubeflow-namespace.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/kubeflow-roles/base > $OUTPUT_FOLDER/37_common_kubeflow-roles.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/istio-1-9/kubeflow-istio-resources/base > $OUTPUT_FOLDER/38_common_kubeflow-istio-resources.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/pipeline/upstream/env/platform-agnostic-multi-user > $OUTPUT_FOLDER/50_apps_pipeline_platform-agnostic-multi-user.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/kfserving/upstream/overlays/kubeflow > $OUTPUT_FOLDER/51_apps_kfserving_kubeflow.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/katib/upstream/installs/katib-with-kubeflow > $OUTPUT_FOLDER/52_apps_katib-with-kubeflow.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/centraldashboard/upstream/overlays/istio > $OUTPUT_FOLDER/53_apps_centraldashboard_istio.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/admission-webhook/upstream/overlays/cert-manager > $OUTPUT_FOLDER/54_apps_admission-webhook_cert-manager.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/jupyter/notebook-controller/upstream/overlays/kubeflow > $OUTPUT_FOLDER/60_apps_jupyter_kubeflow.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/jupyter/jupyter-web-app/upstream/overlays/istio > $OUTPUT_FOLDER/61_apps_jupyter_istio.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/profiles/upstream/overlays/kubeflow > $OUTPUT_FOLDER/62_apps_profiles_kubeflow.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/volumes-web-app/upstream/overlays/istio > $OUTPUT_FOLDER/63_apps_volumes-web-app_istio.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/tensorboard/tensorboards-web-app/upstream/overlays/istio > $OUTPUT_FOLDER/70_apps_tensorboard_istio.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow > $OUTPUT_FOLDER/71_apps_tensorboard_kubeflow.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/training-operator/upstream/overlays/kubeflow > $OUTPUT_FOLDER/72_apps_training-operator_kubeflow.yml
kustomize build $SOURCE_MANIFEST_FOLDER/apps/mpi-job/upstream/overlays/kubeflow > $OUTPUT_FOLDER/73_apps_mpi-job_kubeflow.yml
kustomize build $SOURCE_MANIFEST_FOLDER/common/user-namespace/base > $OUTPUT_FOLDER/74_common_user-namespace.yml

ls -al $OUTPUT_FOLDER
