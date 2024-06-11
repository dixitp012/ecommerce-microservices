#!/bin/bash

echo "Applying Kubernetes ConfigMaps and Secrets..."

# Apply ConfigMaps and Secrets for user-auth-service
echo "Deploying user-auth-service configurations..."
kubectl apply -f ../configmap/user-auth-service-configmap.yml
kubectl apply -f ../configmap/user-auth-service-secret.yml

# Apply ConfigMaps and Secrets for product-service
echo "Deploying product-service configurations..."
kubectl apply -f ../configmap/product-service-configmap.yml
kubectl apply -f ../configmap/product-service-secret.yml

# Apply ConfigMaps and Secrets for order-service
echo "Deploying order-service configurations..."
kubectl apply -f ../configmap/order-service-configmap.yml
kubectl apply -f ../configmap/order-service-secret.yml

# Apply ConfigMaps for api-gateway
echo "Deploying api-gateway configurations..."
kubectl apply -f ../configmap/api-gateway-configmap.yml

echo "Applying Kubernetes Deployments..."

# Apply database deployment
echo "Deploying database..."
kubectl apply -f ../deployments/db-deployment.yml

# Apply RabbitMQ deployment
echo "Deploying RabbitMQ..."
kubectl apply -f ../deployments/rabbitmq-deployment.yml

# Apply Redis deployment
echo "Deploying Redis..."
kubectl apply -f ../deployments/redis-deployment.yml

# Apply user-auth-service deployment
echo "Deploying user-auth-service..."
kubectl apply -f ../deployments/user-auth-service-deployment.yml

# Apply product-service deployment
echo "Deploying product-service..."
kubectl apply -f ../deployments/product-service-deployment.yml

# Apply order-service deployment
echo "Deploying order-service..."
kubectl apply -f ../deployments/order-service-deployment.yml

# Apply api-gateway deployment
echo "Deploying api-gateway..."
kubectl apply -f ../deployments/api-gateway-deployment.yml

echo "Applying Kubernetes Services..."

# Apply database service
echo "Deploying database service..."
kubectl apply -f ../services/db-service.yml

# Apply RabbitMQ service
echo "Deploying RabbitMQ service..."
kubectl apply -f ../services/rabbitmq-service.yml

# Apply Redis service
echo "Deploying Redis service..."
kubectl apply -f ../services/redis-service.yml

# Apply user-auth-service service
echo "Deploying user-auth-service service..."
kubectl apply -f ../services/user-auth-service.yml

# Apply product-service service
echo "Deploying product-service service..."
kubectl apply -f ../services/product-service-service.yml

# Apply order-service service
echo "Deploying order-service service..."
kubectl apply -f ../services/order-service-service.yml

# Apply api-gateway service
echo "Deploying api-gateway service..."
kubectl apply -f ../services/api-gateway-service.yml

echo "Applying Horizontal Pod Autoscalers (HPA)..."

# Apply user-auth-service HPA
echo "Deploying user-auth-service HPA..."
kubectl apply -f ../scaling/user-auth-service-hpa.yml

# Apply product-service HPA
echo "Deploying product-service HPA..."
kubectl apply -f ../scaling/product-service-hpa.yml

# Apply order-service HPA
echo "Deploying order-service HPA..."
kubectl apply -f ../scaling/order-service-hpa.yml

echo "Deployment complete!"
