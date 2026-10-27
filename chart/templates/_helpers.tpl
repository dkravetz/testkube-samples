{{/*
The components for this env: `components` from app.yaml with `envs.<global.env>.components`
merged over them, as YAML. Every template ranges over `include "app.components" . | fromYaml`.
*/}}
{{- define "app.components" -}}
{{- $env := .Values.global.env -}}
{{- $overrides := (get (include "app.envConfig" . | fromYaml) "components") | default dict -}}
{{- range $name, $_ := $overrides -}}
{{- if not (hasKey $.Values.components $name) -}}
{{- fail (printf "envs.%s.components.%s: no such component in components" $env $name) -}}
{{- end -}}
{{- end -}}
{{- $out := dict -}}
{{- range $name, $c := .Values.components -}}
{{- $_ := set $out $name (mergeOverwrite (deepCopy $c) (deepCopy ((get $overrides $name) | default dict))) -}}
{{- end -}}
{{- toYaml $out -}}
{{- end -}}

{{/*
This env's entry in app.yaml's `envs`, as YAML ({} when there is none).
*/}}
{{- define "app.envConfig" -}}
{{- toYaml ((get (.Values.envs | default dict) .Values.global.env) | default dict) -}}
{{- end -}}

{{/*
Labels for a component. Call with (dict "root" $ "name" $name).
*/}}
{{- define "app.labels" -}}
{{ include "app.selectorLabels" . }}
app.kubernetes.io/instance: {{ printf "%s-%s" .root.Values.global.app .root.Values.global.env }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .root.Chart.Name .root.Chart.Version }}
{{- end -}}

{{- define "app.selectorLabels" -}}
app.kubernetes.io/part-of: {{ .root.Values.global.app }}
app.kubernetes.io/component: {{ .name }}
{{- end -}}

{{/*
Name of the Secret the ExternalSecret writes for a component's database.
*/}}
{{- define "app.dbSecretName" -}}
{{ . }}-db
{{- end -}}

{{/*
Where tests reach a component: its route on the internal hostname (BRIEF D21), or its Service
when it has no route. Call with (dict "root" $ "name" $name "component" $c).
*/}}
{{- define "app.origin" -}}
{{- $g := .root.Values.global -}}
{{- with .component.route -}}
{{- printf "http://%s.%s.internal%s" $g.app $g.env (trimSuffix "/" .path) -}}
{{- else -}}
{{- printf "http://%s.%s.svc.cluster.local:%v" .name .root.Release.Namespace .component.port -}}
{{- end -}}
{{- end -}}
