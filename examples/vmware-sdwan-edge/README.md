# Deploy VMware SD-WAN Edge on Azure using Terraform module

The VMware SD-WAN Edge aka VeloCloud Virtual Edge is integrated into the Microsoft Azure marketplace, and the official documentation is available [here](https://techdocs.broadcom.com/us/en/vmware-sde/velocloud-sase/vmware-velocloud-sd-wan/Services/azure-virtual-edge-deployment-guide/sd-wan-azure-virtual-edge-deployment-overview.html).There are multiple options offered by VeloCloud SD-WAN, leveraging distributed VeloCloud Gateways to establish IPsec towards public cloud private network or deploy the Virtual Edge directly in Azure.

This example focus on small branch deployment that demand throughput less than 1G, single virtual edge can be deployed in the private network (Azure vNets). For larger data center deployments that demand multi-gig throughput, Hub clustering can be deployed, but it is out of scope

## How to find an image in Marketplace

You must first obtain the following IDs: Offer, Publisher, SKU, and Version. This can be done using the Azure CLI with the provider name. For example, for VMware:

```bash
# Find VMware SD-WAN Edge images
az vm image list -o table --publisher vmware --offer sol-42222-bbj --all
```

## Prerequisites

The example is intended as a reference and may need to be altered to accommodate specific environments.
VMware VeloCloud SD-WAN only supports a 2-NIC by default:
Attach Interfaces to VMware Instance 
- GE1 – WAN interface—Used to connect to the public network.
- GE2 – LAN interface—Used to connect to internal networks.
- Instance Type: Standard_DS3_v2
- Allocate Public IP and attach to GE1
- Security Groups – Allowed Ports:
      UDP 2426 –VMware Multipath Protocol
      TCP 22 – SSH Access (for Support Access)
      UDP 161 – SNMP
- Public Route Table (UDR): 0.0.0.0/0 to Internet Gateway
- Private Route Table (UDR): 0.0.0.0/0 to Virtual Appliance (Edge GE2 IP address)
- Enable IP Forwarding on all interfaces

## Parameters for Initial Configuration

The initial configuration can be provided using custom data.
The custom_data is a cloud-init script that will be executed on the first boot of the virtual machine.
The script configures the VMware SD-WAN Edge with the provided VCO, activation code, and other settings.
The script is in YAML format and is base64 encoded before being passed to the custom_data parameter.
The script includes the following parameters:
- vce: the configuration for the VMware SD-WAN Edge
- management_interface: false (disables the management interface)
- vco: the VCO address or hostname
- activation_code: the activation code for the VMware SD-WAN Edge
- vco_ignore_cert_errors: true (ignores certificate errors for the VCO)

## Usage

```hcl

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


```

### Deployment Steps

* (optional) Authenticate to AzureRM and switch to the subscription of your choice if necessary.
* Initialize the Terraform module:

                  terraform init

* (optional) Plan your infrastructure to see what will be deployed:

                  terraform plan

* Deploy the infrastructure (you will have to confirm it by typing `yes`):

                  terraform apply

      The deployment takes a few minutes. Wait a few minutes for the SD-WAN Edge to bootstrap.


### Cleanup

To remove the deployed infrastructure, run:

```sh
terraform destroy
```

## Reference
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2, < 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vmware-sdwan-edge"></a> [vmware-sdwan-edge](#module\_vmware-sdwan-edge) | gehoumi/marketplace-linux-vm/azurerm | 1.0.6 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->