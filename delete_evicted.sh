#!/bin/bash

 kubectl get pods --all-namespaces --field-selector 'status.phase==Failed' -o json | kubectl delete -f -
