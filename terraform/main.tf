variable "compartment_ocid" {
  type = string
}

variable "user_ocid" {
  type = string
}

variable "fingerprint" {
  type = string
}

variable "private_key_path" {
  type = string
}

variable "region" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "image_ocid" {
  type = string
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_ocid
  ad_number      = 1
}

provider "oci" {
  tenancy_ocid = var.compartment_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  region = var.region
}

data "template_file" "test" {
  template = <<EOF
all:
  children:
    controlplane:
      hosts:
        controlplane1:
          ansible_user: ubuntu
          ansible_host: ${oci_core_instance.controlplane1.public_ip}
    worker:
      hosts:
        worker1:
          ansible_user: ubuntu
          ansible_host: ${oci_core_instance.worker1.public_ip}
          k3s_server_url: https://${oci_core_instance.controlplane1.private_ip}:6443
EOF
}

resource "null_resource" "local" {
  triggers = {
    template = "${data.template_file.test.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.test.rendered}\" > ../oci-inventory.yml"
  }
}