#!/bin/bash

ADMIN_USER=$1
CICD_NS=$2


echo "Bootstraping ArgoCD"

echo "Creating operator subscription in $CICD_NS"
cat ./argocd/subscription.yaml | CICD_NS=$CICD_NS envsubst | oc apply -f -

while [ `oc get pods -n $CICD_NS | grep argocd-operator | grep "1/1" | wc -l` -eq 0 ]
do
  echo "Waiting for ArgoCD operator to be installed"
  sleep 10
done
echo "ArgoCD operator installed succesfully"

echo "Install ArgoCD"
oc apply -f ./argocd/argocd.yaml -n $CICD_NS

echo "Adding cluster-admin to controller ServiceAccount (WARN: this is just for labs..)"
cat ./argocd/controller-rb.yaml  | CICD_NS=$CICD_NS envsubst | oc apply -f -

echo "Create argocd-manager group"
cat ./ocp/groups/argocd-manager.yaml | ADMIN_USER=$ADMIN_USER envsubst | oc apply -f -


