terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.98.0"
    }
  }
}

provider "azurerm" {
  # It is recommended to pin to a given version of the Provider
  features {
    
  }
}

data "azurerm_virtual_machine" "example" {
  name                = "ansible-test"
  resource_group_name = "personal-rg-jensriis"
}

output "virtual_machine_id" {
  value = data.azurerm_virtual_machine.example.id
}
variable num {
  type = number
  default = 1
}
data "azurerm_public_ip" "pip" {
  name                = "ansible-test-ip "
  resource_group_name = "personal-rg-jensriis"
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.pip.ip_address}"
}

#IP of aws instance copied to a file ip.txt in local system
resource "local_file" "ip" {
    content  = "${data.azurerm_public_ip.pip.ip_address}"
    filename = "ip.txt"
}


#connecting to the Linux OS having the Ansible playbook
resource "null_resource" "nullremote2" {
  
  connection {
      type       = "ssh"
      user        = "azureuser"
      host        = "${data.azurerm_public_ip.pip.ip_address}"
      private_key = "${file("/tmp/ansible-test_key.pem")}"
      timeout     = "2m"
  }
provisioner "remote-exec" {
      
      inline = [
    "cd /tmp/ansible_terraform/aws_instance/",
    "ansible-playbook instance.yml"
  ]

  }
}

output "ip_address" {
   value = data.azurerm_public_ip.pip.ip_address
}
#command to run ansible playbook on remote Linux OS
  



# to automatically open the webpage on local system
resource "null_resource" "nullremote3" {
    depends_on = [null_resource.nullremote2]
    provisioner "local-exec" {
    command = "firefox http://${data.azurerm_public_ip.pip.ip_address}/web/"
  }
}




