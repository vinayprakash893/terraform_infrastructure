resource "aws_instance" "nfs-server" {
  count = 1
	ami = "ami-5a8da735"
	instance_type = "t2.micro"
	tags {
	  Name = "nfs-server"
  subnet_id     = "${aws_subnet.private_subnet.*.id[count.index]}"
	}

  connection {
    user = "ec2-user"
    private_key="${file("/home/ec2-user/.ssh/id_rsa")}"
    agent = false
    timeout = "3m"
  } 

  provisioner "remote-exec" {
    inline = [<<EOF
      sudo yum install -y nfs-kernel-server
      sudo mkdir -p /export/files
      sudo chmod 777 /etc/exports /etc/hosts.allow /export/files
      echo "/export/files *(rw,no_root_squash)" >>  /etc/exports
      nfs = ALL" >> /etc/hosts.allow
      sudo chmod 755 /etc/exports /etc/hosts.allow
      sudo service nfs-kernel-server restart
      sudo showmount -e
            
    EOF
    ]
  }

}

# in client we can set the ssh key

resource "aws_instance" "nfs-client" {
  count = 1
  ami = "ami-5a8da735"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.private_subnet.*.id[count.index]}"
  
  tags {
    Name = "nfs-client"
  }

  connection {
    user = "ec2-user"
    private_key="${file("/home/ec2-user/.ssh/id_rsa")}"
    agent = false
    timeout = "3m"
  } 

  provisioner "remote-exec" {
    inline = [<<EOF
      sudo yum install -y nfs-common
      sudo mkdir -p /export/files
      sudo chmod 777 /export/files
      sudo mount ${aws_instance.nfs-server.private_ip}:/export/files /export/files 
      
      
    EOF
    ]
  }

}