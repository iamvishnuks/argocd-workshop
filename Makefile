# Cluster configs
CONTROL_CLUSTER_CONFIG=control-cluster.yml
APP_CLUSTERS=app1 app2

# Template
TEMPLATE=templates/cluster-secret.yml.tpl
MANIFEST_DIR=manifests

.PHONY: all create-clusters get-kubeconfigs install-argocd generate-cluster-secrets

all: create-clusters get-kubeconfigs install-argocd generate-cluster-secrets

create-clusters:
	kind create cluster --config=$(CONTROL_CLUSTER_CONFIG)
	@for cluster in $(APP_CLUSTERS); do \
		kind create cluster --config=$${cluster}-cluster.yml; \
	done

get-kubeconfigs:
	@for cluster in $(APP_CLUSTERS); do \
		kind get kubeconfig --name $$cluster > kind-$$cluster.kubeconfig; \
	done

install-argocd:
	kubectl ctx kind-control
	kubectl create namespace argocd || true
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm upgrade --install argocd argo/argo-cd -n argocd --version 7.7.9 --values values.yml

generate-cluster-secrets:
	@mkdir -p $(MANIFEST_DIR)
	@for cluster in $(APP_CLUSTERS); do \
		KUBECONFIG_FILE=kind-$$cluster.kubeconfig; \
		CLUSTER_NAME=$$(yq '.clusters[0].name' $$KUBECONFIG_FILE); \
		SERVER_IP=$$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $$cluster-control-plane); \
		CA_DATA=$$(yq '.clusters[0].cluster."certificate-authority-data"' $$KUBECONFIG_FILE); \
		CERT_DATA=$$(yq '.users[0].user."client-certificate-data"' $$KUBECONFIG_FILE); \
		KEY_DATA=$$(yq '.users[0].user."client-key-data"' $$KUBECONFIG_FILE); \
		CLUSTER_NAME=$$CLUSTER_NAME SERVER_IP=$$SERVER_IP CA_DATA=$$CA_DATA CERT_DATA=$$CERT_DATA KEY_DATA=$$KEY_DATA envsubst < $(TEMPLATE) > $(MANIFEST_DIR)/$$cluster-secret.yaml; \
		echo "Generated: $(MANIFEST_DIR)/$$cluster-secret.yaml"; \
	done
