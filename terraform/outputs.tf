output "instance_public_ip" {
  description = "La IP fija (Elastic IP) de tu servidor"
  value       = aws_eip.wordpress_eip.public_ip
}

output "ssh_connection" {
  description = "Comando listo para copiar y pegar en tu terminal"
  value       = "ssh -i ~/.ssh/LightsailDefaultKey-us-east-1-p1.pem ubuntu@${aws_eip.wordpress_eip.public_ip}"
}
