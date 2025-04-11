locals {
  VCO              = "vcoxxxxx"
  ActivationKey    = "xxxxxxxxxxxx"
  IgnoreCertErrors = false
  admin_ssh_keys = [{
    public_key = "ssh-rsa AAAAB3xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  }]
}

module "vmware-sdwan-edge" {
  source                       = "gehoumi/marketplace-linux-vm/azurerm"
  version                      = "1.0.6"
  name                         = "VMware-SD-WAN-Edge"
  accept_marketplace_agreement = true # Accept the marketplace agreement for the image if required

  source_image_reference = {
    offer     = "sol-42222-bbj"
    publisher = "vmware-inc"
    sku       = "vmware_sdwan_452"
    version   = "4.5.2"
  }

  size           = "Standard_D2d_v4"
  admin_ssh_keys = local.admin_ssh_keys

  # The address space for the virtual network. This is a CIDR block that defines the range of IP addresses for the virtual network.
  address_space = ["172.16.0.0/16"]

  # The subnets for the virtual network. Each subnet is defined by its name and CIDR block.
  # The subnets are used to segment the network into different address spaces.
  # The subnets are defined in a map, where each entry contains the name of the subnet and its CIDR block.
  network_interfaces = {
    "if-nic1" = {
      name                            = "public-subnet-wan-ge1"
      address_prefixes                = ["172.16.0.0/24"]
      network_security_group          = "VELO_vVCE_SG"
      enable_storage_service_endpoint = true
      create_public_ip                = true
    },
    "if-nic2" = {
      name             = "private-subnet-lan-ge2"
      address_prefixes = ["172.16.1.0/24"]
    },
  }

  # The network security groups for the virtual network. Each network security group is defined by its name and a set of rules.
  # The rules are defined in a map, where each entry contains the name of the rule and its properties.
  additional_network_security_groups = {
    "VELO_vVCE_SG" = {
      name        = "VELO_vVCE_SG"
      description = "Security Group for VMware SD-WAN Edge"
      rules = {
        "Allow-SSH" = {
          source_address_prefixes      = ["0.0.0.0/0"]
          description                  = "Allow SSH access to the VMware SD-WAN Edge"
          priority                     = 100
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_range            = "*"
          destination_port_ranges      = ["22"]
          source_address_prefixes      = ["0.0.0.0/0"]
          destination_address_prefixes = ["0.0.0.0/0"]
        },
        "Allow-UDP-2426" = {
          name                         = "Allow-UDP-2426"
          description                  = "Allow UDP 2426 for VMware Multipath Protocol"
          priority                     = 101
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Udp"
          source_port_range            = "*"
          destination_port_ranges      = ["2426"]
          source_address_prefixes      = ["0.0.0.0/0"]
          destination_address_prefixes = ["0.0.0.0/0"]
        },
        "Allow-SNMP" = {
          name                         = "Allow-SNMP"
          description                  = "Allow SNMP access to the VMware SD-WAN Edge"
          priority                     = 102
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Udp"
          source_port_range            = "*"
          destination_port_ranges      = ["161"]
          source_address_prefixes      = ["0.0.0.0/0"]
          destination_address_prefixes = ["0.0.0.0/0"]
        }
      }
    }
  }

  # Initial configuration 
  custom_data = base64encode(
    <<EOT
#cloud-config
velocloud:
 vce:
  management_interface: false
  vco: ${local.VCO}
  activation_code: ${local.ActivationKey}
  vco_ignore_cert_errors: ${local.IgnoreCertErrors}
EOT
  )

  # The following example creates a public route table and a private route table.
  # The public route table is associated with the public subnet and contains a default route to the Internet Gateway.
  # The private route table is associated with the private subnet and contains a default route to the virtual appliance (Edge GE2 IP address).
  route_tables = {
    "public-route-table" = {
      name = "public-route-table"
      routes = [
        {
          name           = "default-route"
          address_prefix = "0.0.0.0/0"
          next_hop_type  = "Internet"
        }
      ]
    },
    "private-route-table" = {
      name = "private-route-table"
      routes = [
        {
          name                   = "default-route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "172.16.1.4" # IP Address used for Edge LAN Interface GE2
        }
      ]
    }
  }

}

