#!/bin/bash
# Script to check the application status on the EC2 instance

# Check if an IP address was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <ec2-public-ip>"
  exit 1
fi

EC2_IP=$1

echo "Checking application status on $EC2_IP..."

# Check if the server is reachable
echo -n "Server reachability: "
if ping -c 1 $EC2_IP &> /dev/null; then
  echo "OK"
else
  echo "FAILED"
  echo "Cannot reach the server. Check if it's running and security groups allow ping."
  exit 1
fi

# Check if the web application is responding
echo -n "Web application: "
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EC2_IP/)
if [ "$HTTP_STATUS" = "200" ]; then
  echo "OK (HTTP $HTTP_STATUS)"
else
  echo "FAILED (HTTP $HTTP_STATUS)"
fi

echo "Application URL: http://$EC2_IP/"
echo ""
echo "To check container status manually, SSH into the instance and run:"
echo "  ssh ubuntu@$EC2_IP -i your-key.pem"
echo "  sudo docker ps"
echo "  sudo docker logs myappcontainer"