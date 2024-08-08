variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  default = "ami-0603cb4546aa25a8b"
}

variable "key_name" {
  description = "SSH key name to use for the instance"
}

variable "key_file" {
  description = "Path to the SSH private key file"
}
