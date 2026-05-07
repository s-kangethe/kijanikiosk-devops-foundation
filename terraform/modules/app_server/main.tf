resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name        = var.name
    Environment = var.environment
  }

  user_data = <<-EOF
              #!/bin/bash
              echo "App ${var.name} running on port ${var.port}" > /home/ubuntu/app.txt
              EOF
}
