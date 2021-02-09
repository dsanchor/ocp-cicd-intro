#!/bin/bash

CICD_NS=$1
USER=$2
USER_NS=$3

echo "Bootstraping user $USER (CI/CD ns=$CICD_NS)"

echo "Creating namespaces..."
cat ./ocp/ns/namespaces.yaml | USER_NS=$USER_NS envsubst | oc apply -f -

echo "Create self-contained user group"
cat ./ocp/groups/regular-user.yaml | USER=$USER USER_NS=$USER_NS envsubst | oc apply -f -

echo "Adding view role to ns=$CICD_NS"
cat ./ocp/rb/cicd-ns-rb.yaml | USER=$USER CICD_NS=$CICD_NS USER_NS=$USER_NS envsubst | oc apply -f -

echo "Adding admin role to its ns"
cat ./ocp/rb/user-admin.yaml | USER=$USER USER_NS=$USER_NS envsubst | oc apply -f -

echo "Adding system:image-puller from $USER_NS-dev & $USER_NS-prod ns to $USER_NS ns"
cat ./ocp/rb/user-ns-image-puller.yaml| USER_NS=$USER_NS envsubst | oc apply -f -

echo "Creating ArgoCD AppProject for user ${USER_NS}"
cat ./argocd/app-project.yaml | USER_NS=$USER_NS CICD_NS=$CICD_NS envsubst | oc apply -f -

echo "Adding ArgoCD Apps edit role for user ${USER_NS}"
cat ./ocp/rb/argocd-apps-editor.yaml | USER_NS=$USER_NS CICD_NS=$CICD_NS envsubst | oc apply -f -