# monk-dataops

## Start 

Register account at https://monk.io/join

Get Monk - https://docs.monk.io/monk-in-10/

Start `monkd -d` and login to Monk.

```bash
monk login --email=<email> --password=<password>
```

## Deploy

Load the template
```bash
monk load airbyte.yaml 
```

Deploy the stack 
```bash
monk run airbyte/system
```

## Create a cluster

Create new cluster 
```bash
monk cluster new --name=dataops-cluster --link=true
```

Prepare cloud credentials:
- GCP service account key `/usr/local/etc/key.json` or other directory with full Compute access role.
```bash
monk cluster provider add -p gcp -f /usr/local/etc/key.json
```
- AWS IAM role with full EC2 access role and save your secret keys under `~/.aws/credentials` - Monk will automatically source from `[default]`
```ini
[default]
aws_access_key_id=<aws_access_key_id>
aws_secret_access_key=<aws_secret_access_key>
```
```bash
monk cluster provider add -p aws
```

Provision cluster node instances
```bash
monk cluster grow --provider=gcp --name=gcp-instance --tag=dataops --instance-type=n2-standard-2 --region=europe-west4 --disk-size=10 -m 4
```
