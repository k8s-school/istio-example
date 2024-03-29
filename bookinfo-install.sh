#!/bin/bash

# Install Istio bookinfo application
# See https://istio.io/docs/examples/bookinfo/

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
. "$DIR"/env.sh
ISTIO_DIR="$DIR/istio-${ISTIO_VERSION}"

NS="bookinfo"

kubectl delete ns -l "$NS=true"

echo "Create a new namespace called bookinfo and add istio-injection label"
kubectl create ns "$NS"
kubectl label ns "$NS" "$NS=true"
kubectl label namespace "$NS" istio-injection=enabled
kubectl get namespace -L istio-injection
kubectl config set-context $(kubectl config current-context) --namespace="$NS"

kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/platform/kube/bookinfo.yaml

kubectl --namespace="$NS" wait --timeout=400s --for=condition=available deploy --all
kubectl get services

# To confirm that the Bookinfo application is running,
# send a request to it by a curl command from some pod, for example from ratings:
kubectl wait pod -l app=ratings --for=condition=ready
kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') \
  -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"

# Ingress
# https://istio.io/latest/docs/setup/getting-started/#ip
kubectl apply -f "$ISTIO_DIR"/samples/bookinfo/networking/bookinfo-gateway.yaml

istioctl analyze

