{{/*
Expand the name of the chart.
*/}}
{{- define "filebeat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "filebeat.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Use the fullname if the serviceAccount value is not set
*/}}
{{- define "filebeat.serviceAccount" -}}
{{- if .Values.serviceAccount }}
{{- .Values.serviceAccount -}}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Labels to use on every resource
*/}}
{{- define "filebeat.labels" -}}
labels:
  app.kubernetes.io/name: "{{ template "filebeat.fullname" . }}"
  helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  app.kubernetes.io/managed-by: "{{ .Release.Service }}"
  app.kubernetes.io/instance: "{{ .Release.Name }}"
  app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
{{- end -}}

{{/*
Reuse metadata for deployment and daemonset
*/}}
{{- define "filebeat.metadata" -}}
name: {{ template "filebeat.fullname" .root }}
{{ include "filebeat.labels" .root }}
    {{- range $key, $value := .values.labels }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
  {{- if .values.annotations }}
annotations:
  {{- range $key, $value := .values.annotations }}
  {{ $key }}: {{ $value | quote }}
  {{- end }}
  {{- end }}
{{- end -}}

{{- define "filebeat.podmeta" -}}
selector:
  matchLabels:
    app.kubernetes.io/name: "{{ template "filebeat.fullname" .root }}"
    app.kubernetes.io/managed-by: "{{ .root.Release.Service }}"
    app.kubernetes.io/instance: "{{ .root.Release.Name }}"
template:
  metadata:
    annotations:
      {{- range $key, $value := .values.podAnnotations }}
      {{ $key }}: {{ $value | quote }}
      {{- end -}}
      {{/* This forces a restart if the configmap has changed */}}
      {{- if .values.filebeatConfig }}
      configChecksum: {{ include (print .root.Template.BasePath "/configmap.yaml") .root | sha256sum | trunc 63 }}
      {{- end }}
{{ include "filebeat.labels" .root | indent 4 }}
      {{- range $key, $value := .values.podLabels }}
      {{ $key }}: {{ $value | quote }}
      {{- end }}
{{- end -}}
