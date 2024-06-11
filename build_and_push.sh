#!/bin/bash

# Function to build and push a Docker image for a specific service
build_and_push_service() {
  local username=$1
  local service=$2
  local tag=$3

  if [[ ! " ${services[@]} " =~ " ${service} " ]]; then
    echo "Error: Invalid service name '$service'"
    echo "Valid services are: ${services[*]}"
    exit 1
  fi

  echo "Building Docker image for $service with tag $tag..."
  docker build -t $username/$service:$tag ./$service
  if [ $? -ne 0 ]; then
    echo "Error: Failed to build Docker image for $service"
    exit 1
  fi

  echo "Pushing Docker image for $service to Docker Hub with tag $tag..."
  docker push $username/$service:$tag
  if [ $? -ne 0 ]; then
    echo "Error: Failed to push Docker image for $service"
    exit 1
  fi

  echo "Docker image for $service built and pushed successfully with tag $tag."
}

# Function to build and push Docker images for all services
build_and_push_all() {
  local username=$1
  local tag=$2
  for service in "${services[@]}"; do
    build_and_push_service $username $service $tag
  done
}

# Main script logic
if [ $# -lt 2 ]; then
  echo "Usage: $0 <username> [all | service_name] [tag]"
  exit 1
fi

username=$1
shift

tag="latest"
if [ $# -eq 2 ]; then
  tag=$2
fi

services=("user_auth_service" "product_service" "order_service" "api_gateway" "nginx")

if [ "$1" == "all" ]; then
  build_and_push_all $username $tag
else
  build_and_push_service $username $1 $tag
fi