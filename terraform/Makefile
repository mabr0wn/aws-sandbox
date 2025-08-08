# Makefile for Terraform multi-env deployments

# Required variables (must be passed in)
# Example: make deploy env=dev region=us-east-1 stack=00-network-foundation
ifndef env
  $(error env is not set. Example: make deploy env=dev region=us-east-1 stack=00-network-foundation)
endif
ifndef region
  $(error region is not set. Example: make deploy env=dev region=us-east-1 stack=00-network-foundation)
endif
ifndef stack
  $(error stack is not set. Example: make deploy env=dev region=us-east-1 stack=00-network-foundation)
endif

# Paths
ENV_PATH    = envs/$(env)/$(region)/$(stack)/terraform.tfvars
STACK_PATH  = stacks/$(stack)

# Validate paths before running
check-paths:
	@if [ ! -f $(ENV_PATH) ]; then \
		echo "ERROR: Terraform vars file not found at $(ENV_PATH)"; \
		exit 1; \
	fi
	@if [ ! -d $(STACK_PATH) ]; then \
		echo "ERROR: Stack directory not found at $(STACK_PATH)"; \
		exit 1; \
	fi

# Deploy target
deploy: check-paths
	cd $(STACK_PATH) && terraform init && terraform apply -var-file=$(abspath $(ENV_PATH)) -auto-approve

# Plan target
plan: check-paths
	cd $(STACK_PATH) && terraform init && terraform plan -var-file=$(abspath $(ENV_PATH))

# Destroy target
destroy: check-paths
	cd $(STACK_PATH) && terraform destroy -var-file=$(abspath $(ENV_PATH)) -auto-approve

# Build all stacks in order for a given env/region
# Usage: make deploy-all env=dev region=us-east-1
STACKS_ORDER = 00-network-foundation 10-security-foundation 20-shared-services 30-app-ecs 30-app-eks 30-serverless-app 40-data-platform
deploy-all:
	@for s in $(STACKS_ORDER); do \
		echo "\n=== Deploying $$s ==="; \
		$(MAKE) deploy env=$(env) region=$(region) stack=$$s; \
	done

plan-all:
	@for s in $(STACKS_ORDER); do \
		echo "\n=== Planning $$s ==="; \
		$(MAKE) plan env=$(env) region=$(region) stack=$$s; \
	done

destroy-all:
	@for s in $(STACKS_ORDER); do \
		echo "\n=== Destroying $$s ==="; \
		$(MAKE) destroy env=$(env) region=$(region) stack=$$s; \
	done
