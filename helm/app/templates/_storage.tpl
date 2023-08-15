{{- define "resource.persistentVolumeClaim" }}
{{- if .root.Values.persistence.enabled }}
{{- with index .root.Values.persistence .name }}
{{- if .enabled }}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ tpl (.claimName | default "") $.root | default (print $.root.Release.Name "-" $.name) | quote }}
  labels:
    {{- include "chart.labels" $.root | nindent 4 }}
    app.kubernetes.io/component: {{ $.serviceName | default $.name | quote }}
    app.service: {{ print $.root.Release.Name "-" ($.serviceName | default $.name) | quote}}
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
{{- with (pick . "selector" "volumeMode" "volumeName") }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "statefulSet.volumeClaimTemplate" }}
{{- with index .root.Values.persistence .name }}
metadata:
  name: {{ tpl (.claimName | default "") $.root | default (print $.root.Release.Name "-" $.name) | quote }}
  labels:
    {{- include "chart.selectors" $.root | nindent 4 }}
    app.kubernetes.io/component: {{ $.serviceName | default $.name | quote }}
    app.service: {{ print $.root.Release.Name "-" ($.serviceName | default $.name) | quote}}
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
{{- with (pick . "selector" "volumeMode" "volumeName") }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}