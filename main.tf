resource "aws_vpc" "evergreen_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    projectname = "ngo_project"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.evergreen_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1"
  tags = {
    projectname = "ngo_project"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.evergreen_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1"
  tags = {
    projectname = "ngo_project"
  }
}
data "http" "myip" {
  url = "https://checkip.amazonaws.com/"
}
resource "aws_security_group" "web" {
  name        = "web"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.evergreen_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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
  ingress  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
   cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  tags = {
    projectname = "ngo_project"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "postgres"
  engine_version       = "16.3"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.postgres16"
  skip_final_snapshot  = true
vpc_security_group_ids = [aws_security_group.rds.id]
db_subnet_group_name = aws_db_subnet_group.db_subnets.name
}
resource "aws_instance" "webserver" {
  ami           = "ami-0c55b159cbfafe1d0"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.web.id]
}
output "ec2ip" {
    value = aws_instance.webserver.public_ip
  }

resource "aws_route_table_association" "name" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.name.id

}


output "databaseurl" {
  value = aws_db_instance.default.endpoint
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.evergreen_vpc.id
}
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.name.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}
resource "aws_db_subnet_group" "db_subnets" {
  name       = "db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]

  tags = {
    projectname = "ngo_project"
  }
}
resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.evergreen_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.web.id]  
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_route_table" "name" {
  vpc_id = aws_vpc.evergreen_vpc.id
}