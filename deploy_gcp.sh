#!/bin/bash

set -ex

GCP_KEY="/usr/local/etc/key2.json"

monk login --email=$MONCC_MAIL --password=$MONCC_APASS

monk c new -n dataops-cluster
monk c provider add -p gcp -f $GCP_KEY

monk cluster grow --provider=gcp \
    --name=dataops \
    --tag=dataops-cluster \
    --instance-type=n2-standard-2 \
    --region=europe-west4 \
    --zone=europe-west4-c \
    --disk-size=10 -m 4

monk load chaos-cluster.yaml
monk run meltano/system
