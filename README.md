# HTTP Load Balancer Example

[![button](http://gstatic.com/cloudssh/images/open-btn.png)](https://console.cloud.google.com/cloudshell/open?git_repo=https://github.com/GoogleCloudPlatform/terraform-google-lb-http&working_dir=examples/basic&page=shell&tutorial=README.md)

<a href="https://concourse-tf.gcp.solutions/teams/main/pipelines/tf-examples-lb-http-basic" target="_blank">
<img src="https://concourse-tf.gcp.solutions/api/v1/teams/main/pipelines/tf-examples-lb-http-basic/badge" /></a>

This example creates a global HTTP forwarding rule to forward traffic to instance groups in the us-west1 and us-east1 regions.

**Figure 1.** *diagram of Google Cloud resources*

![architecture diagram](https://raw.githubusercontent.com/GoogleCloudPlatform/terraform-google-lb-http/master/examples/multi-mig-http-lb/diagram.png)

## Install Terraform

Install Terraform if it is not already installed (visit [terraform.io](https://terraform.io) for other distributions):

```
../terraform-install.sh
```

## Set up the environment

Set the project, replace `YOUR_PROJECT` with your project ID:

```
PROJECT=YOUR_PROJECT
```

```
gcloud config set project ${PROJECT}
```

Create [service account](https://console.cloud.google.com/iam-admin/serviceaccounts) and use it in terraform.tfvars


or  edit *terrafrom.tfvars*

```bash
cp terraform.tfvars.examples terrform.tfvars
```

## Get Terraform Google Modules

Pre download modules  to work. Better so, if you can edit the source code of the module itself.

```bash
cd ../
git clone https://github.com/terraform-google-modules/terraform-google-project-factory
git clone https://github.com/terraform-google-modules/terraform-google-cloud-nat.git
git clone https://github.com/terraform-google-modules/terraform-google-lb-http.git
git clone https://github.com/terraform-google-modules/terraform-google-vm.git
```

## Run Terraform

```
terraform init
terraform apply
```

## Testing

1. Wait for the load balancer to be provisioned:

```
./test.sh
```

2. Open the URL of the load balancer in your browser:

```
echo http://$(terraform output load-balancer-ip)
```

You should see the instance details from the region closest to you.

## Test balancing to other region *not working yet*

Resize the instance group of your closest region to cause traffic to flow to the other group.

1. If you are getting traffic from `group1` (us-west1), scale group 1 to 0 instances:

```
TF_VAR_group1_size=0 terraform apply
```

2. Otherwise scale group 2 (us-east1) to 0 instances:

```
TF_VAR_group2_size=0 terraform apply
```

3. Open the external IP again and verify you see traffic from the other group:

```
echo http://$(terraform output load-balancer-ip)
```

> It may take several minutes for the global load balancer to be created and the backends to register.

## Cleanup

1. Remove all resources created by terraform:

```
terraform destroy
```