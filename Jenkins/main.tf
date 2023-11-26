resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_availability_zones" "available" { }

resource "aws_default_subnet" "default_az1" {
    availability_zone = data.aws_availability_zones.available.names[0]
    tags = {
        Name = "Default subnet for ap-south-1a"
    }
}

# Security Group

resource "aws_security_group" "web_traffic" {
  name        = "Allow web traffic"
  description = "inbound ports for ssh and standard http and everything outbound"
  vpc_id = aws_default_vpc.default.id
  dynamic "ingress" {
    iterator = port
    for_each = var.ingressrules
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "TCP"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Terraform" = "true"
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0287a05f0ef0e9d9a" # ap-south-1
  instance_type = "t2.medium"
  subnet_id = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [ aws_security_group.web_traffic.id ]
  key_name = "vault"

  tags = {
    Name = "jenkins_server"
  }
}

resource "null_resource" "name" {

  #SSH into ec2 instance

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/Downloads/vault.pem")
    host = aws_instance.jenkins_server.public_ip
  }
  # copy the install_jenkins.sh file from local to ec2 instance

  provisioner "file" {
    source = "install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
    
  }

  # set permission and execute the install_jenkins.sh file

  provisioner "remote-exec" {
    inline = [ 
      "sudo chmod +x /tmp/install_jenkins.sh",
      "sh /tmp/install_jenkins.sh"
     ]
  }

  depends_on = [ 
    aws_instance.jenkins_server
   ]

}
  
