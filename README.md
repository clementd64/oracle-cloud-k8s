Bootstrap a kubernetes cluster on Oracle Cloud Infrastructure with Always Free resources.

This will deploy 2 VM.Standard.A1.Flex with 2 CPU, 12GB of memory, 50GB of storage and an additional 50GB disks.  
And create an k3s cluster with 1 control plane node and 1 worker node.

The Traefik ingress controller is disabled to match a more traditional Kubernetes setup.
The service load balancer is disabled, not compatible with kube-proxy in ipvs mode. Use a NodePort with a fixed port.
The local-storage provider is disabled because this setup was primarily destined to test a Rook deployment.

## Installation

1. Go to https://cloud.oracle.com/ and create a account if you don't have one.
2. Generate your API Key on https://cloud.oracle.com/identity/domains/my-profile/api-keys. Download the generated private keys.
3. Create the terraform variable file `terraform/terraform.tfvars` (variable value can be found on the configuration file preview)
```
compartment_ocid = ""
fingerprint = ""
user_ocid = ""
region = ""
private_key_path = "<path to your private keyfile>"

# Image ocid, can be found at https://docs.oracle.com/en-us/iaas/images/
# tested on Canonical-Ubuntu-22.04-Minimal-aarch64-2022.06.19-0
image_ocid = ""
ssh_key = "<Your public ssh key>"
```
4. Download the required terraform provider `terraform -chdir=terraform init`
5. Provision the cluster with `terraform -chdir=terraform apply`
6. Bootstrap the cluster with `ansible-playbook -i oci-inventory.yml playbook/install-k3s.yaml`

## Todo
- IPv6 support
- Better CNI (Oracle seems to block direct routing even with the src/dst IP check disabled)