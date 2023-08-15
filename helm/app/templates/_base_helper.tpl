{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.appVersion | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common selectors
*/}}
{{- define "chart.selectors" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "application.volumes.backend" }}{{ end }}
{{- define "application.volumeMounts.backend" }}{{ end }}

{{- define "application.volumes.all" }}{{ end }}
{{- define "application.volumeMounts.all" }}{{ end }}

{{- define "application.volumes.wwwDataPaths" }}{{ end }}

{{- define "application.volumes.console" -}}
{{- if .Values.persistence.mountVolumesOnConsole -}}
{{- template "application.volumes.backend" . -}}
{{- template "application.volumes.all" . -}}
{{- end -}}
{{- end }}
{{- define "application.volumeMounts.console" -}}
{{- if .Values.persistence.mountVolumesOnConsole -}}
{{- template "application.volumeMounts.backend" . -}}
{{- template "application.volumeMounts.all" . -}}
{{- end -}}
{{- end }}

{{/*
A template to fully resolve services that extend template services
*/}}
{{- define "service.resolved" -}}
{{- $service := index $.root.Values.services $.service_name -}}
{{- $extended := (dict) -}}
{{- range $service.extends -}}
{{ $_ := mergeOverwrite $extended (include "service.resolved" (dict "root" $.root "service_name" .) | fromYaml) }}
{{- end -}}
{{- $_ := mergeOverwrite $extended $service -}}
{{ $extended | toYaml }}
{{- end -}}

{{- define "service.environment.secret" }}
{{- if and .service.environment_secrets (.service.enabled | default true) }}
{{- if .root.Values.global.sealed_secrets.enabled }}
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
{{- else }}
apiVersion: v1
kind: Secret
{{- end }}
metadata:
  name: {{ print .root.Release.Name "-" .service_name }}
  labels:
    {{- include "chart.labels" .root | nindent 4 }}
    app.kubernetes.io/component: {{ .component | default .service_name }}
  annotations:
    argocd.argoproj.io/sync-wave: "1"
{{- if .root.Values.global.sealed_secrets.enabled }}
    sealedsecrets.bitnami.com/scope: {{ .root.Values.global.sealed_secrets.scope }}
{{- if ne .root.Values.global.sealed_secrets.scope "strict" }}
    sealedsecrets.bitnami.com/{{ .root.Values.global.sealed_secrets.scope }}: "true"
{{- end }}
spec:
  encryptedData:
{{- index .service.environment_secrets | toYaml | nindent 4 }}
  template:
    metadata:
      labels:
        {{- include "chart.labels" .root | nindent 8 }}
        app.kubernetes.io/component: {{ .component | default .service_name }}
{{- else }}
stringData:
{{- index .service.environment_secrets | toYaml | nindent 2 -}}
{{- end }}
{{- end }}
{{- end }}

{{- define "service.environment" }}
{{- with (mergeOverwrite (dict) (deepCopy (.service.environment | default (dict))) (deepCopy (.service.environment_dynamic | default (dict)))) -}}
env:
{{- range $key, $value := . }}
- name: {{ $key | quote }}
{{- if kindIs "string" $value }}
  value: {{ tpl $value $.root | quote }}
{{- else if kindIs "map" $value }}
  {{- tpl ($value | toYaml) $.root | nindent 2 }}
{{- else }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- if or .service.environment_secrets .service.envFrom }}
envFrom:
  {{- if .service.environment_secrets }}
  - secretRef:
      name: {{ print $.root.Release.Name "-" .serviceName }}
  {{- end }}
  {{- with .service.envFrom }}
  {{- tpl (. | toYaml) $.root | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "pod.topologySpreadConstraints" }}
{{- $topologySpreadConstraints := $.service.topologySpreadConstraints | default $.root.Values.global.topologySpreadConstraints }}
{{- if eq (len $topologySpreadConstraints) 0 -}}
[]
{{- else }}
{{- range $topologySpreadConstraints }}
- 
  {{- with (pick . "labelSelector" "matchLabelKeys" "maxSkew" "topologyKey" "whenUnsatisfiable") }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  {{- if not (hasKey . "maxSkew") }}
  maxSkew: 1
  {{- end }}
  {{- if not (hasKey . "whenUnsatisfiable") }}
  whenUnsatisfiable: ScheduleAnyway
  {{- end }}
  {{- if not (or (hasKey . "labelSelector") (hasKey . "matchLabelKeys")) }}
  labelSelector:
    matchLabels:
      app.service: {{ print $.root.Release.Name "-" $.serviceName }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
