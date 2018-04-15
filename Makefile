plan-stage:
	TF_VAR_env=staging terraform plan -state=staging.tfstate

plan-prod:
	TF_VAR_env=production terraform plan -state=production.tfstate

apply-stage:
	TF_VAR_env=staging terraform apply -state=staging.tfstate

apply-prod:
	TF_VAR_env=production terraform apply -state=production.tfstate
