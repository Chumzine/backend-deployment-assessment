output "vpc_id" {
  description = "ID of the MuchTodo VPC"
  value       = aws_vpc.main.id
}

output "availability_zones" {
  description = "The two Availability Zones used by the subnets"
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the two private subnets"
  value       = aws_subnet.private[*].id
}

output "bastion_public_ip" {
  description = "Elastic IP address of the Bastion host"
  value       = aws_eip.bastion.public_ip
}

output "backend_private_ip" {
  description = "Private IP address of the Backend EC2 instance"
  value       = aws_instance.backend.private_ip
}

output "mongodb_private_ip" {
  description = "Private IP address of the MongoDB EC2 instance"
  value       = aws_instance.mongodb.private_ip
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}
