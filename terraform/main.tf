############################
############ VPC ###########
############################

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "devops-vpc"
  }
}

#######################################
############ Subnet Pública ###########
#######################################

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  availability_zone = var.availability_zone # ✅ ACA VA

  tags = {
    Name = "public-subnet"
  }
}

#########################################
############ Internet Gateway ###########
#########################################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

####################################
############ Route Table ###########
####################################

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

########################################################
############ Asociación subnet - Route Table ###########
########################################################

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt.id
}

#######################################
############ Security Group ###########
#######################################

resource "aws_security_group" "web_sg" {
  name   = "web-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # después podés restringirlo
  }

  ingress {
    description = "SSH"
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # después podés restringirlo
  }


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

####################################
############ EC2 ###########
####################################

resource "aws_instance" "wordpress" {
  ami           = "ami-0ec10929233384c7f"
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id

  # ✅ Ejecución automática del bootstrap
  user_data_base64 = base64gzip(file("${path.module}/../scripts/bootstrap-secure.sh"))

  # ✅ Configuración del almacenamiento de 30GB
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3" # Recomendado por mejor performance/precio
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "wordpress-devops"
  }
}

####################################
############ Elastic IP ############
####################################

resource "aws_eip" "wordpress_eip" {
  instance = aws_instance.wordpress.id
  domain   = "vpc"

  tags = {
    Name = "wordpress-static-ip"
  }
}
