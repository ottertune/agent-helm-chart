{{/*
Expand the name of the chart.
*/}}
{{- define "..name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "..fullname" -}}
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
{{- define "..chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "..labels" -}}
helm.sh/chart: {{ include "..chart" . }}
{{ include "..selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "..selectorLabels" -}}
app.kubernetes.io/name: {{ include "..name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "..serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "..fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Provides the name of the Configmap.
*/}}
{{- define "..configmapName" -}}
{{ include "..fullname" .}}-configmap
{{- end }}

{{/*
Returns True if the user provided AWS credentials.
Fail when secret key is set but access id isn't.
Fail when access id is set but secret key isn't.
*/}}
{{- define "..awsCredsEnabled" -}}
{{- $accessID := .Values.aws.accessKeyID | trim -}}
{{- $secretKey := .Values.aws.secretAccessKey | trim -}}
{{- $accessIDEmpty := empty $accessID -}}
{{- $secretKeyEmpty := empty $secretKey -}}
{{- $accessIDNotEmpty := not $accessIDEmpty -}}
{{- $secretKeyNotEmpty := not $secretKeyEmpty -}}
{{- if and $accessIDEmpty $secretKeyNotEmpty -}}
{{- fail "You provided an AWS Secret Key, but no Access Key ID. You must provide either both or neither." -}}
{{- end }}
{{- if and $accessIDNotEmpty $secretKeyEmpty -}}
{{- fail "You provided an AWS Access Key ID, but no Secret Access Key. You must provide either both or neither." -}}
{{- end -}}
{{- and $accessIDNotEmpty $secretKeyNotEmpty -}}
{{- end -}}
