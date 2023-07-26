variable "user_id" {
}

variable "instance_name" {
}

variable "privkey_path" {
  type    = string
  default = "~/.ssh/id_rsa"
}

variable "pubkey_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "network_name" {
  description = "The network to be used."
  default     = "openstack-network"
}

variable "image_name" {
  description = "Image to use for dev instance"
  type        = string
  default     = "CentOS7"
}

data "openstack_images_image_v2" "image" {
  name        = var.image_name
  most_recent = true
}

variable "flavor_name" {
  description = "The flavor id to be used."
  default     = "xlarge"
}

variable "volume_size" {
  description = "The size of volume in GB used to instantiate the instance"
  default     = "100"
}

variable "security_groups" {
  description = "List of security group"
  type        = list(any)
  default     = ["default"]
}

variable "project_id" {
  description = "openstack project id"
  default     = ""
}

variable "external_network_name" {
  type    = string
  default = "uap-external"
}
