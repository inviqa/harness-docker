{{- define "resource.persistentVolumeClaim" }}
{{- if .root.Values.persistence.enabled }}
{{- with index .root.Values.persistence .name }}
{{- if . | dig "create" .enabled }}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ include "persistence.claimName" $ | quote }}
  labels:
    {{- include "chart.labels" $.root | nindent 4 }}
    app.kubernetes.io/component: {{ $.serviceName | default $.name | quote }}
    app.service: {{ print $.root.Release.Name "-" ($.serviceName | default $.name) | quote}}
    {{- with .labels }}
    {{- . | toYaml | nindent 4 }}
    {{- end }}
  {{- with (pick . "annotations") }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
spec:
  accessModes:
    - {{ .accessMode | quote }}
  resources:
    requests:
      storage: {{ .size | quote }}
{{- if .storageClass }}
{{- if (eq "-" .storageClass) }}
  storageClassName: ""
{{- else }}
  storageClassName: {{ .storageClass | quote }}
{{- end }}
{{- end }}
{{- with (pick . "dataSource" "dataSourceRef" "selector" "volumeMode" "volumeName") }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "statefulSet.volumeClaimTemplate" }}
{{- with index .root.Values.persistence .name }}
metadata:
  name: {{ include "persistence.claimName" $ | quote }}
  labels:
    {{- include "chart.selectors" $.root | nindent 4 }}
    app.kubernetes.io/component: {{ $.serviceName | default $.name | quote }}
    app.service: {{ print $.root.Release.Name "-" ($.serviceName | default $.name) | quote }}
    {{- with .labels }}
    {{- . | toYaml | nindent 4 }}
    {{- end }}
  {{- with (pick . "annotations") }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
spec:
  accessModes:
    - {{ .accessMode | quote }}
  resources:
    requests:
      storage: {{ .size | quote }}
{{- if .storageClass }}
{{- if (eq "-" .storageClass) }}
  storageClassName: ""
{{- else }}
  storageClassName: {{ .storageClass | quote }}
{{- end }}
{{- end }}
{{- with (pick . "dataSource" "dataSourceRef" "selector" "volumeMode" "volumeName") }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}

{{- define "persistence.claimName" -}}
{{- with index .root.Values.persistence .name -}}
{{- tpl (.claimName | default "") $.root | default (print $.root.Release.Name "-" $.name) -}}
{{- end -}}
{{- end }}
