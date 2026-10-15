{{/*
命名空间：优先取 .Values.namespace，否则用 Release.Namespace
*/}}
{{- define "mychart.namespace" -}}
{{- if .Values.namespace -}}
{{- .Values.namespace -}}
{{- else -}}
{{- .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{/*
Deployment 名称
*/}}
{{- define "mychart.deploy" -}}
{{- printf "%s-deploy" .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Service 名称
*/}}
{{- define "mychart.service" -}}
{{- printf "%s-svc" .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Gateway 名称
*/}}
{{- define "mychart.gateway" -}}
{{- printf "%s-gw" .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end -}}
