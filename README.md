# rds-s3-database-backup

This script allows uploading gzipped rds postgres backups to amazon s3.
Database credentials are retrieved from aws parameter store.


## environment variables

`ENVIRONMENT` allows tagging different environments, we use `prod` and
`dev` as possible values.

`IDENTIFIER` is a database identifier, e.g. `db`. The identifier is
used for querying configuration options and for naming the result in s3.

`REGION` is the aws region to operate in.

## parameter store keys

- `/$ENVIRONMENT/cron/backup/$IDENTIFIER/host`: database host name
- `/$ENVIRONMENT/cron/backup/$IDENTIFIER/name`: database name
- `/$ENVIRONMENT/cron/backup/$IDENTIFIER/user`: database user name
- `/$ENVIRONMENT/cron/backup/$IDENTIFIER/password`: database password
- `/$ENVIRONMENT/cron/backup/$IDENTIFIER/bucket`: target s3 bucket

## output

After completion, the script creates a gzipped backup in the target s3
bucket named `$IDENTIFIER-YYYY-MM-DD.sql.gz`. All backups are stored in
`STANDARD_IA` storage class.
