NO_COLOR=\033[0m
INFO_COLOR=\033[0;33m
OCTO=""


PHONY: start
start: octoshield snake


.PHONY: snake
snake:
	@minikube start -p Snake
	@minikube profile Snake
	$(call pp,"Creating 'monitoring' namespace...")
	@kubectl create namespace monitoring  > /dev/null
	$(call pp,"Starting Prometheus...")
	@kubectl create configmap prometheus-config --from-file=prometheus/prometheus-config.yaml -nmonitoring  > /dev/null
	@kubectl apply -f prometheus/prometheus.yaml -nmonitoring > /dev/null
	@kubectl create -f prometheus/prometheus-node-exporter.yaml -nmonitoring > /dev/null
	$(call pp,"Prometheus URL:")
	@minikube service --url --namespace=monitoring prometheus
	$(call pp,"Starting Alertmanager...")
	@kubectl create configmap alertmanager-config --from-file=alertmanager/alertmanager-config.yaml -nmonitoring  > /dev/null
	@kubectl create -f alertmanager/alertmanager.yaml -nmonitoring  > /dev/null
	$(call pp,"Alertmanager URL:")
	@minikube service --url --namespace=monitoring alertmanager
	$(call pp,"Starting Grafana...")
	@kubectl create -f grafana/grafana.yaml -nmonitoring  > /dev/null
	$(call pp,"Grafana URL \(default credentials admin/admin\):")
	@minikube service --url --namespace=monitoring grafana # Add Prometheus as a datasource http://prometheus:9090 (defaults to admin/admin)
	
	
	$(call pp,"Octoshield URL:")
	@rm -rf build/octoshield/config.yml
	@minikube profile Octoshield > /dev/null
	$(call pp,"$(OCTO)")
	@echo "token: TEST_TOKEN\nserverUrl: $(shell minikube service octoshield --url) \nenv: PREPROD\ntags:\n  pod: snake" >> build/octoshield/config.yml
	$(call pp,"build snake")
	minikube profile Snake > /dev/null
	@sudo docker build -t snake build/ > /dev/null
	$(call pp,"tag snake")
	@sudo docker tag snake kelysa/snake:lastest > /dev/null
	$(call pp,"push snake")
	@sudo docker push kelysa/snake > /dev/null
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
	@minikube start -p Octoshield
	minikube profile Octoshield > /dev/null
	$(call pp,"starting Octoshield")
	@kubectl apply -f octoshield
	$(call pp,"Octoshield URL:")
	@minikube service octoshield --url 

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

PHONY: stop
stop:
	$(call pp,"Deleting snake and octoshield cluster")
	@minikube delete 
	@minikube profile Octoshield
	@minikube delete
	$(call pp,"Done...")

define pp
    @echo "$(INFO_COLOR)$(1)$(NO_COLOR)"
endef
