### Locals
locals {
  name = "${var.environment}-${var.project_name}"
}

### VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  
  tags = merge({ Name = local.name }, var.common_tags)
}

### Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ Name = local.name }, var.common_tags)
}

### Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  
  tags = merge({ Name = "${local.name}-public-${count.index}" }, var.common_tags)
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]
  
  tags = merge({ Name = "${local.name}-private-${count.index}" }, var.common_tags)
}

resource "aws_subnet" "db" {
  count             = length(var.db_subnet_cidr)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.db_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]
  
  tags = merge({ Name = "${local.name}-db-${count.index}" }, var.common_tags)
}

# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "${local.name}-db-subnet-group"
  subnet_ids = [aws_subnet.db[*].is]

  tags = merge(
    {
    Name = "${local.name}-db-subnet-group"
    },
    var.common_tags
  ) 
}

### Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ Name = "${local.name}-public" }, var.common_tags)
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ Name = "${local.name}-private" }, var.common_tags)
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags   = merge({ Name = "${local.name}-db" }, var.common_tags)
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}

### NAT Gateway (Optional)
resource "aws_eip" "eip" {
  count  = var.enable_nat ? 1 : 0
  domain = "vpc"
  tags   = merge({ Name = local.name }, var.common_tags)
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public[0].id
  
  tags       = merge({ Name = local.name }, var.common_tags)
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route" "private" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}
resource "aws_route" "db" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.db.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

### Flow Logs
resource "aws_cloudwatch_log_group" "vpc_log_group" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "vpc-flow-logs"
  retention_in_days = 7
}

resource "aws_iam_role" "vpc_flow_log_role" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "vpcFlowLogRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  role  = aws_iam_role.vpc_flow_log_role[0].id
  name = "${local.name}-vpc-flow-cw"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.vpc_log_group[0].arn}:*"
    }]
  })
}

resource "aws_flow_log" "vpc_flow_logs" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  log_destination      = aws_cloudwatch_log_group.vpc_log_group[0].arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
  iam_role_arn         = aws_iam_role.vpc_flow_log_role[0].arn
  tags = merge(
    {
      Name = local.name
    },
    var.common_tags
  )
}

