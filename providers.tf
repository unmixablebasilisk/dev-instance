terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.49.0"
    }

    # ansible = {
    #   source  = "ansible/ansible"
    #   version = "1.1.0"
    # }
  }
}

provider "openstack" {
  # Configuration options
  insecure = "true"
}

# provider "ansible" {
# }
