.PHONY: build rmi

build:
	docker build -t tomologic/$(shell basename $(CURDIR)) .

rmi:
	docker rmi tomologic/$(shell basename $(CURDIR))

check-upgrades:
	@printf "Configured Google Cloud SDK version: "
	@grep -m1 GOOGLE_CLOUD_SDK_VERSION Dockerfile | awk -F= '{print $$2}'
	@echo "Google Cloud SDK changelog: https://cloud.google.com/sdk/docs/release-notes"
	@printf "Configured Helm version: "
	@grep -m1 HELM_VERSION Dockerfile | awk '{print $$3}'
	@printf "Available Helm version: "
	@curl -sL https://api.github.com/repos/helm/helm/releases/latest | jq -r .tag_name
	@echo "Helm changelog: https://github.com/helm/helm/releases"
