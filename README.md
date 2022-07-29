# OtterTune Agent Helm Chart

This repository contains a Helm Chart to deploy the OtterTune agent to a Kubernetes cluster.

## Installation

To install, first add the Helm repo with your CLI:

```bash
helm repo add ottertune https://ottertune.github.io/agent-helm-chart/
```

Next, refresh your local Helm index.

```bash
helm repo update
```

Finally, create a YAML file with your values:

```yaml
# my-values.yaml
aws:
  region: "us-east-2"
  accessKeyID: "<FAKE_ACCESS_ID>"
  secretAccessKey: "<FAKE_SECRET_KEY>"

ottertune:
  postgresDBName: "my-database-name" # Only for Postgres Databases
  dbIdentifier: "my-database"
  dbUsername: "example-username"
  dbPassword: "example-password"
  apiKey: "example-api-key"
  dbKey: "example-db-uuid"
  orgID: "example-org-uuid"
```

Then, install the chart:

```bash
helm install -f my-values.yaml my-release-name ottertune/ottertune-agent
```

That's it! Observe your release with 

```bash
kubectl logs deployment/my-release-name-ottertune-agent
```

### Using an Existing Secret

**<u>This is highly recommended.</u>** This chart creates a Kubernetes `Secret` to store your API Key. However, Helm stores `values` in plaintext in `etcd` on the cluster, so your API Key will be accessable if you provide it as a `value`. To get around this, you can create a `Secret` yourself and provide this chart with the `Secret`'s name instead. For example:

```bash
export OT_API_KEY="my-api-key" 
export SECRET_NAME="MySecretName"
kubectl create secret generic $SECRET_NAME --from-literal api-key="$OT_API_KEY"
```

Then, you can provide a `value.yaml` resembling this:

```yaml
# my-values.yaml
aws:
  region: "us-east-2"
  accessKeyID: "<FAKE_ACCESS_ID>"
  secretAccessKey: "<FAKE_SECRET_KEY>"

ottertune:
  dbIdentifier: "my-database"
  dbUsername: "example-username"
  dbPassword: "example-password"
  apiKeyExistingSecret: "MySecretName"
  dbKey: "example-db-uuid"
  orgID: "example-org-uuid"
```

### Using --Set

Just like with all Helm charts, you can use `--set` anywhere you use a key in a `values.yaml` file.

For example:

```bash
helm install my-release ottertune/ottertune-agent \
  --set aws.region="us-east-2" \
  --set aws.accessKeyID="<REDACTED>" \
  --set aws.secretAccessKey="<REDACTED>" \
  --set ottertune.dbIdentifier="my-database" \
  --set ottertune.dbUsername="example-username" \
  --set ottertune.dbPassword="example-password" \
  --set ottertune.apiKeyExistingSecret="awesome-secret" \
  --set ottertune.dbKey="example-db-uuid" \
  --set ottertune.orgID="example-org-uuid"
```

### Eliding AWS Credentials

**This is highy recommended.** You can omit `aws.accessKeyID` and `aws.secretAccessKey` by providing a `ServiceAccount` annotation with a IAM role granting database access. AWS [offers](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to attach IAM roles to Kubernetes `ServiceAccount`s. This allows the OtterTune Agent to connect to AWS RDS, eliminating the need to inject credentials into the Agent's container via environment variables. You should ensure that the role has the following [permissions](https://docs.ottertune.com/info/connect-your-database-to-ottertune/add-database/agent#policies).

For example, if you have an IAM Role OTAgentRole, and the ARN is arn:aws:iam::123456789:role/OTAgentRole, then you should update your `my-values.yaml` file with the following block:

```yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789:role/OTAgentRole
  name: OTAgentServiceAccount
```

This will ensure that the agent uses this service account which should give it the necessary IAM permissions.

## Contributing

If there's a feature you'd like added, please open an issue on this repository and tag one of the maintainers. We also accept pull requests for new features. 

### Cutting a Release

Cutting and deploying releases is automated with CircleCI. To cut a new release, follow the following steps:

1. Update the chart `version` is `Chart.yaml`. This version is used to create the GitHub Release tag, and used again in the chart repository index to describe the versions of the chart available to users.

2. Commit your change in `version` to the `main` branch, pushing the change to the remote.

3. Create a tag matching the regex `release-.*`. This is expected to be a Semver version without the leading `v`, like `0.1.1`  or `2.5.4`.

   ```bash
   git tag -a 0.1.4 -m "Cutting new release"
   ```

4. Push the created tag to the remote.

   ```bash
   git push --tags
   ```

5. At this point, CircleCI will create a new GitHub release named `ottertune-agent-0.1.4` . It will package the chart into a tarball and attach it to the Release for download.

6. Next CircleCI will update the index located at `docs/index.yaml`. This index file describes the chart metadata available to users of the chart. CircleCI will then push a commit to `main` with the updated `docs/index.yaml` file. That's the last step! ***NB:*** At the time of writing, CircleCI is using an invalid API Key to push the commit, so this step will fail until a new API Key can be provided. 

## GitHub Pages

This repository uses GitHub Pages to serve the chart repository. The repository settings are configured to deploy a static website hosted at https://ottertune.github.io/agent-helm-chart/ . The content of this static website is found on the `main` branch at `docs/`. GitHub will automatically update the website when the contents of this directory change. There is no index page, but you can visit `https://ottertune.github.io/agent-helm-chart/index.yaml` to see the index of the chart repository.


## Chart Parameters and Configurables

| Key                                   | Type    | Default                          | Description                                                  |
| ------------------------------------- | ------- | -------------------------------- | ------------------------------------------------------------ |
| image.repository                      | String  | "public.ecr.aws/ottertune/agent" |                                                              |
| image.pullPolicy                      | String  | "IfNotPresent"                   |                                                              |
| aws.region                            | String  | ""                               | **Required**: The AWS region that database is located in.    |
| aws.accessKeyID                       | String  | ""                               | An AWS Access Key ID allowing RDS access. If enabled, you must also provide `aws.secretAccessKey`. Only required if you are not providing credentials via a ServiceAccount or `ottertune.apiKeyExistingSecret` |
| aws.secretAccessKey                   | String  | ""                               | An AWS Secret Access Key allowing RDS access. If enabled, you must also provide `aws.accessKeyID` |
| ottertune.dbIdentifier                | String  | ""                               | **Required:** The AWS identifier for the database you want to monitor. This is the name of the RDS instance. |
| ottertune.dbUsername                  | String  | ""                               | The name of the database user that the agent will use to connect to the database. |
| ottertune.dbPassword                  | String  | ""                               | The password of the database user that the agent will use to connect to the database. |
| ottertune.apiKey                      | String  | ""                               | **Required**, if `ottertune.apiKeyExistingSecret` is not enabled. The OtterTune API Key assigned to your organization. This value is mutually exclusive with `ottertune.apiKeyExistingSecret`. |
| ottertune.dbKey                       | String  | ""                               | A unique UUID provided by OtterTune, used to identify this database. |
| ottertune.orgID                       | String  | ""                               | A unique UUID provided by OtterTune, used to identify your organization. |
| ottertune.postgresDBName              | String  | ""                               | **Required for Postgres databases:** This is the name of the database in Postgres which the agent will monitor. |
| ottertune.apiKeyExistingSecret        | String  | ""                               | The name of a secret in the cluster. This secret must provide a key `api-key` , which contains the OtterTune API Key (see `ottertune.apiKey`). |
| engine.mysql.auroraWorkaround.enabled | Boolean | false                            | If using an old version of MySQL (5.6 or earlier), set to true. This will change the SSL configuration to use a legacy mode. This is **required** for MySQL Aurora databases. |
| imagePullSecrets                      | Array   | []                               |                                                              |
| serviceAccount.create                 | Boolean | true                             | Whether to create a `ServiceAccount` for the `Deployment`    |
| serviceAccount.annotations            | Map     | {}                               | Annotations to add to the `ServiceAccount`                   |
| serviceAccount.name                   | String  | ""                               | Override the name of the `ServiceAccount`.                   |
| fullnameOverride                      | String  | ""                               |                                                              |
| resources                             | Map     | {}                               | Set resource requests and limits on the `Deployment`.        |
| nodeSelector                          | Map     | {}                               |                                                              |
| tolerations                           | List    | []                               |                                                              |
| affinity                              | Map     | {}                               |                                                              |
| podAnnotations                        | Map     | {}                               |                                                              |
| podSecurityContext                    | Map     | {}                               |                                                              |
| serverUrlOverride                     | String  | ""                               | On-prem customers only. If you need to change the URL of the OtterTune SaaS, you can override that value here. |
| replicaCount                          | Number  | 1                                | Please do not edit this value. The agent only supports 1 replica at this time. |

