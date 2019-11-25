NO_COLOR=\033[0m
INFO_COLOR=\033[0;33m
OCTO=""


PHONY: start
start: octoshield snake


.PHONY: snake
snake:
	@kubectl create namespace monitoring  > /dev/null
	$(call pp,"Starting Prometheus...")
	@kubectl create configmap prometheus-config --from-file=prometheus/prometheus-config.yaml -nmonitoring  > /dev/null
	@kubectl apply -f prometheus/prometheus.yaml -nmonitoring > /dev/null
	@kubectl create -f prometheus/prometheus-node-exporter.yaml -nmonitoring > /dev/null
	$(call pp,"Starting Alertmanager...")
	@kubectl create configmap alertmanager-config --from-file=alertmanager/alertmanager-config.yaml -nmonitoring  > /dev/null
	@kubectl create -f alertmanager/alertmanager.yaml -nmonitoring  > /dev/null
	$(call pp,"Starting Grafana...")
	@kubectl create -f grafana/grafana.yaml -nmonitoring  > /dev/null
	
	
	$(call pp,"starting snake")
	@minikube addons enable metrics-server > /dev/null
	@kubectl create -f snake/deployment.yml > /dev/null
	@kubectl create -f snake/hpa.yml > /dev/null
	@kubectl create -f snake/service.yml > /dev/null
	$(call pp,"Pacman URL:")
	@minikube service snake --url
	$(call pp,"Done...")

.PHONY: octoshield
octoshield:
	$(call pp,"starting Octoshield")
	@kubectl apply -f octoshield

.PHONY: gremlin
gremlin:
	@kubectl create secret generic gremlin-team-cert --from-file=./gremlin/gremlin.cert --from-file=./gremlin/gremlin.key
	@kubectl -n kube-system create serviceaccount tiller
	@kubectl create clusterrolebinding tiller \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:tiller
	@helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -
	@helm repo add gremlin https://helm.gremlin.com
	@helm install --set gremlin.teamID=2513549e-e90d-5a61-90f1-f9f6afcda8c8 gremlin/gremlin

define pp
    @echo "$(INFO_COLOR)$(1)$(NO_COLOR)"
endef
