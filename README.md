

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

