#!/bin/bash

NAMESPACE="$1"

#check for params
if [ "x$NAMESPACE" == "x" ]; then
    echo "Env var NAMESPACE is empty. Provide a valid target NAMESPACE"
    exit 2;
fi

## destroy elastic / kibana
helm uninstall --namespace $NAMESPACE kibana
helm uninstall --namespace $NAMESPACE elasticsearch
