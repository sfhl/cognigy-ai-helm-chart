{{/*
Expand the name of the chart.
*/}}
{{- define "helm-chart-cognigy.ai-new.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm-chart-cognigy.ai-new.fullname" -}}
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
{{- define "helm-chart-cognigy.ai-new.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm-chart-cognigy.ai-new.labels" -}}
helm.sh/chart: {{ include "helm-chart-cognigy.ai-new.chart" . }}
{{ include "helm-chart-cognigy.ai-new.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm-chart-cognigy.ai-new.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm-chart-cognigy.ai-new.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm-chart-cognigy.ai-new.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm-chart-cognigy.ai-new.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "image.pullSecrets" -}}
  {{- $pullSecrets := list -}}

  {{- if and (.Values.imageCredentials.registry) (.Values.imageCredentials.username) (.Values.imageCredentials.password) -}}
      {{- $pullSecrets = append $pullSecrets "cognigy-registry-token" -}}
  {{- else if .Values.imageCredentials.pullSecrets -}}
    {{- range .Values.imageCredentials.pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- else -}}
    {{ required "A valid value for .Values.imageCredentials is required!" .Values.imageCredentials.registry }}
    {{ required "A valid value for .Values.imageCredentials is required!" .Values.imageCredentials.username }}
    {{ required "A valid value for .Values.imageCredentials is required!" .Values.imageCredentials.password }}
    {{ required "A valid value for .Values.imageCredentials is required!" .Values.imageCredentials.pullSecrets }}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) -}}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Return the proper smtp password Secret Name
*/}}
{{- define "smtp.password.secretName" -}}
  {{- $smtpPasswordName := "" -}}

  {{- if .Values.smtpPasswordExistingSecret -}}
    {{- $smtpPasswordName = .Values.smtpPasswordExistingSecret -}}
  {{- else -}}
    {{- $smtpPasswordName = "cognigy-smtp" -}}
  {{- end -}}

  {{- printf "%s" (tpl $smtpPasswordName $) -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "common.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return the proper Management Ui Credentials Secret Name
*/}}
{{- define "managementUiCredentials.secretName.render" -}}
  {{- $managementUiCredentialsName := "" -}}

  {{- if .Values.managementUiCredentialsExistingSecret -}}
    {{- $managementUiCredentialsName = .Values.managementUiCredentialsExistingSecret -}}
  {{- else -}}
    {{- $managementUiCredentialsName = "cognigy-management-ui-creds" -}}
  {{- end -}}

  {{- printf "%s" (tpl $managementUiCredentialsName $) -}}
{{- end -}}

{{/*
Return the proper mongodb credentials Secret Name
*/}}
{{- define "mongodbCredentials.secretName.render" -}}
  {{- $mongodbCredentialsSecretName := "" -}}

  {{- if .Values.mongodb.auth.existingSecret -}}
    {{- $mongodbCredentialsSecretName = .Values.mongodb.auth.existingSecret -}}
  {{- else -}}
    {{- $mongodbCredentialsSecretName = "mongodb-connection-creds" -}}
  {{- end -}}

  {{- printf "%s" (tpl $mongodbCredentialsSecretName $) -}}
{{- end -}}

{{/*
Return the proper tls certificate Secret Name
*/}}
{{- define "tlsCertificate.secretName.render" -}}
  {{- $tlsCertificateSecretName := "" -}}

  {{- if and (.Values.tls.enabled) (.Values.traefik.enabled) -}}
    {{- if .Values.tls.existingSecret -}}
      {{- $tlsCertificateSecretName = .Values.tls.existingSecret -}}
    {{- else if and (.Values.tls.crt) (.Values.tls.key) -}}
      {{- $tlsCertificateSecretName = "cognigy-traefik" -}}
    {{- else -}}
      {{ required "A valid value for .Values.tls is required!" .Values.tls.crt }}
      {{ required "A valid value for .Values.tls is required!" .Values.tls.key }}
      {{ required "A valid value for .Values.tls is required!" .Values.tls.existingSecret }}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $tlsCertificateSecretName)) -}}
tls:
  - secretName: {{- printf "%s" (tpl $tlsCertificateSecretName $) | indent 1 -}}
  {{- end -}}
{{- end -}}

{{/*
Return the proper amazonCredentials Secret Name
*/}}
{{- define "amazonCredentials.secretName.render" -}}
  {{- $amazonCredentialsSecretName := "" -}}

  {{- if .Values.amazonCredentials.existingSecret -}}
    {{- $amazonCredentialsSecretName = .Values.amazonCredentials.existingSecret -}}
  {{- else -}}
    {{- $amazonCredentialsSecretName = "cognigy-amazon-credentials" -}}
  {{- end -}}

  {{- printf "%s" (tpl $amazonCredentialsSecretName $) -}}
{{- end -}}

{{/*
Return the proper cognigyLiveAgent Credentials Secret Name
*/}}
{{- define "liveAgentCredentials.secretName.render" -}}
  {{- $liveAgentCredentialsSecretName := "" -}}

  {{- if .Values.cognigyLiveAgent.existingSecret -}}
    {{- $liveAgentCredentialsSecretName = .Values.cognigyLiveAgent.existingSecret -}}
  {{- else -}}
    {{- $liveAgentCredentialsSecretName = "cognigy-live-agent-credentials" -}}
  {{- end -}}

  {{- printf "%s" (tpl $liveAgentCredentialsSecretName $) -}}
{{- end -}}

