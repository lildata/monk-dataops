# monk-dataops

## Start 

Register account at https://monk.io/join

Get Monk - https://docs.monk.io/getting-started/monk-in-10-minutes

Start `monkd -d` and login to Monk.

```bash
monk login --email=<email> --password=<password>
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

## Deploy

Load the template
```bash
monk load meltano.yaml 
```

Deploy the stack 
```bash
monk run meltano/system
```
```
✔ Starting job... DONE
✔ Preparing nodes DONE
✔ Preparing containers DONE
✔ Checking/pulling images DONE
✔ Updating containers DONE
✔ ✨meltano/system updated successfully
🔩 meltano/system
 ├─🧊 Peer QmWchAjNtXxAmCagxBBQHq3Meu7xCewjuF6HdSxkX625Fj
 │  └─📦 templates-local-meltano-tap-db-postgres
 │     ├─🧩  postgres:12-alpine
 │     ├─💾 /var/lib/monkd/volumes/db_data -> /var/lib/postgresql/data
 │     └─🔌 open 34.91.139.250:5432 (0.0.0.0:5432) -> 5432
 ├─🧊 Peer QmSU2gZdftuTzxVJ7nfiHW4uyFsYPK1Eeyw8BfVzrD7tav
 │  └─📦 templates-local-meltano-meltano-db-postgres
 │     ├─🧩  postgres:12-alpine
 │     ├─💾 /var/lib/monkd/volumes/db_data -> /var/lib/postgresql/data
 │     └─🔌 open 34.91.205.208:5432 (0.0.0.0:5432) -> 5432
 ├─🧊 Peer QmTBiVJw2dnXwNYdTALrYhSYvYaPtwK5F5aHkoeudop4er
 │  └─📦 templates-local-meltano-meltano-ui-meltano
 │     ├─🧩  meltano/meltano:latest
 │     ├─💾 /var/lib/monkd/volumes/output -> /project
 │     └─🔌 open 35.204.91.138:5000 -> 5000
 └─🧊 Peer QmVfrRMUaVciRbP1tjt1T3j5gxXKeh97SdHxrFrWpGctAn
    └─📦 templates-local-meltano-target-db-postgres
       ├─🧩  postgres:12-alpine
       ├─💾 /var/lib/monkd/volumes/db_data -> /var/lib/postgresql/data
       └─🔌 open 34.90.152.210:5432 (0.0.0.0:5432) -> 5432
```

Look for meltano-ui workload if you'd like to use their GUI (above `35.204.91.138:5000` - your instance IP will be different)
```
 ├─🧊 Peer QmTBiVJw2dnXwNYdTALrYhSYvYaPtwK5F5aHkoeudop4er
 │  └─📦 templates-local-meltano-meltano-ui-meltano
 │     ├─🧩  meltano/meltano:latest
 │     ├─💾 /var/lib/monkd/volumes/output -> /project
 │     └─🔌 open 35.204.91.138:5000 -> 5000
```

## Create dummy data in the source database

Run this command to create a small template with test data to create data integration pipeline for.
```bash
monk do meltano/tap-db/init-data
```
```
✔ Got action parameters
✔ Parse parameters success
✔ Running action: 
NOTICE:  table "lookup" does not exist, skipping
SELECT 2
✨ Took: 5s
```

## Add extractors and loaders

Extractors are data sources (in our example Postgres) where the data is being synced from.
```bash
monk do meltano/meltano-ui/add-loader name=target-postgres host=templates-local-meltano-target-db-postgres dbname=postgres schema=public username=postgres password=password
```
Loaders are target databases (in our example Postgres) or storage where the data from extractors will be integrated to.
```bash
monk do meltano/meltano-ui/add-extractor name=tap-postgres host=templates-local-meltano-tap-db-postgres dbname=postgres schema=public username=postgres password=password replication-method=FULL_TABLE
```

## Schedule data pipeline

To schedule or edit your pipeline run below command specyfing name of your pipeline as well as extractor and loader.
```bash
monk do meltano/meltano-ui/create-pipeline pipeline=p-to-p extractor=tap-postgres loader=target-postgres frequency=@once
```
To execute the pipeline run
```bash
monk do meltano/meltano-ui/etl pipeline=p-to-p extractor=tap-postgres loader=target-postgres
```
