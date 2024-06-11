#!/bin/bash

echo "Applying Kubernetes Deployments..."
kubectl apply -f ../deployments/db-deployment.yml
kubectl apply -f ../deployments/rabbitmq-deployment.yml
kubectl apply -f ../deployments/redis-deployment.yml
kubectl apply -f ../deployments/user-auth-service-deployment.yml
kubectl apply -f ../deployments/product-service-deployment.yml
kubectl apply -f ../deployments/order-service-deployment.yml
kubectl apply -f ../deployments/api-gateway-deployment.yml

echo "Applying Kubernetes Services..."
kubectl apply -f ../services/db-service.yml
kubectl apply -f ../services/rabbitmq-service.yml
kubectl apply -f ../services/redis-service.yml
kubectl apply -f ../services/user-auth-service.yml
kubectl apply -f ../services/product-service-service.yml
kubectl apply -f ../services/order-service-service.yml
kubectl apply -f ../services/api-gateway-service.yml

echo "Deployment complete!"
