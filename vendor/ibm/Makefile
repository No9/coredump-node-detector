help: ## This help. Ensure KUBECONFIG env variable is set.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

pvc: ## Create persitent volume claim.
	@kubectl apply -f pvc.yaml

install-handler: ## Deletes then installs the dump handler in ibmcloud.
	@kubectl delete -f ibmcloud.yaml && kubectl apply -f ibmcloud.yaml

install-cos: ## I ibmcloud
	@install-cos.sh