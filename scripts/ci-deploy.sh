#! /bin/bash
# exit script when any command ran here returns with non-zero exit code
set -e

COMMIT_SHA1=$CIRCLE_SHA1

# We must export it so it's available for envsubst
export COMMIT_SHA1=$COMMIT_SHA1

# since the only way for envsubst to work on files is using input/output redirection,
#  it's not possible to do in-place substitution, so we need to save the output to another file
#  and overwrite the original with that one.
envsubst <./kube/do-sample-deployment.yml >./kube/do-sample-deployment.yml.out
mv ./kube/do-sample-deployment.yml.out ./kube/do-sample-deployment.yml

echo "$KUBERNETES_CLUSTER_CERTIFICATE" | base64 --decode > cert.crt

echo "---------------- KUBERNETES CLUSTER CERTIFICATE"
cat cert.crt

echo "---------------- KUBERNETES SERVER "
echo "$KUBERNETES_SERVER"

echo "---------------- KUBERNETES TOKEN"


echo "$KUBERNETES_TOKEN"

curl --cacert ${KUBERNETES_CLUSTER_CERTIFICATE} --header "Authorization: Bearer ${TOKEN}" -X GET ${KUBERNETES_SERVER}/api


./kubectl \
  --kubeconfig=/dev/null \
  --server=$KUBERNETES_SERVER \
  --certificate-authority=cert.crt \
  --token=$KUBERNETES_TOKEN \
  apply -f ./kube/