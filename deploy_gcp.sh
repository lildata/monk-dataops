#!/bin/bash

monk login

monk cluster new -n dataops-cluster
monk cluster provider add -p gcp

monk cluster grow --provider=gcp \
    --name=dataops \
    --tag=dataops-cluster \
    --instance-type=n2-standard-2 \
    --region=europe-west4 \
    --zone=europe-west4-c \
    --disk-size=10 -m 4

monk cluster peers