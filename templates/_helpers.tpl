{{/*
Expand the name of the chart.
*/}}
{{- define "ottertune-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ottertune-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ottertune-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ottertune-agent.labels" -}}
helm.sh/chart: {{ include "ottertune-agent.chart" . }}
{{ include "ottertune-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ottertune-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ottertune-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ottertune-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ottertune-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Provides the name of the Configmap.
*/}}
{{- define "ottertune-agent.configmap-name" -}}
{{ include "ottertune-agent.fullname" .}}-configmap
{{- end }}

{{/*
This template provides the name of the Secret the agent will
use to extract sensitive credentials. If the user does not provide
an existing secret, this chart will use a default secret name, and
inject sensitive credentials into that secret.
*/}}
{{- define "ottertune-agent.secret-name" -}}
{{ default (include "ottertune-agent.secret-default-name" . ) .Values.ottertune.apiKeyExistingSecret -}}
{{end}}

{{/*
Provides the default name of the OtterTune-provided Secret. If the user
provides an existing secret, use that secret name instead.
*/}}
{{- define "ottertune-agent.secret-default-name" -}}
{{ include "ottertune-agent.fullname" .}}-secret
{{- end }}

{{/*
Returns True if the user provided AWS credentials.
Fail when secret key is set but access id isn't.
Fail when access id is set but secret key isn't.
*/}}
{{- define "ottertune-agent.awsCredsEnabled" -}}
{{- $accessID := .Values.aws.accessKeyID | trim -}}
{{- $secretKey := .Values.aws.secretAccessKey | trim -}}
{{- $accessIDEmpty := empty $accessID -}}
{{- $secretKeyEmpty := empty $secretKey -}}
{{- if and $accessIDEmpty (not $secretKeyEmpty) -}}
{{- fail "You provided an AWS Secret Key, but no Access Key ID. You must provide either both or neither." -}}
{{- end }}
{{- if and (not $accessIDEmpty) $secretKeyEmpty -}}
{{- fail "You provided an AWS Access Key ID, but no Secret Access Key. You must provide either both or neither." -}}
{{- end -}}
{{- not (and $accessIDEmpty $secretKeyEmpty) -}}
{{- end -}}
