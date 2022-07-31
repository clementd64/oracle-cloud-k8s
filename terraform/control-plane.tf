resource "oci_core_instance" "controlplane1" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.main_subnet.id
    assign_public_ip = true
    hostname_label   = "controlplane1"
    skip_source_dest_check = true
  }

  source_details {
    source_type = "image"
    source_id = var.image_ocid
    boot_volume_size_in_gbs = "50"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_key
  }
}

resource "oci_core_volume" "controlplane1_vol" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domain.ad.name
  size_in_gbs         = "50"
}

resource "oci_core_volume_attachment" "controlplane1_vol" {
  attachment_type = "paravirtualized"
  instance_id = oci_core_instance.controlplane1.id
  volume_id   = oci_core_volume.controlplane1_vol.id
}