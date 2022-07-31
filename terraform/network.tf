resource "oci_core_virtual_network" "kubernetes" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  dns_label      = "k8s"
}

resource "oci_core_subnet" "main_subnet" {
  cidr_block        = "10.1.0.0/24"
  display_name      = "Main Subnet"
  dns_label         = "main"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.kubernetes.id
  security_list_ids = [oci_core_security_list.security_list.id]
  route_table_id    = oci_core_route_table.main_route_table.id
  dhcp_options_id   = oci_core_virtual_network.kubernetes.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "k8s_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.kubernetes.id
}

resource "oci_core_route_table" "main_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.kubernetes.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.k8s_internet_gateway.id
  }
}

resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.kubernetes.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless = true
  }

  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
    stateless = true
  }
}