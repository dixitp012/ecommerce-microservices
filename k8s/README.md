
# E-commerce Microservices Setup with Kubernetes

## Prerequisites

- Minikube
- kubectl

## Setup

1. **Start Minikube**:

```bash
minikube start --cpus=4 --memory=2200
```

2. **Deploy Services**:

Navigate to the `deployment` directory and run the deployment script:

```bash
cd deployment
chmod +x deploy.sh  # Make the script executable if permissions are not given
./deploy.sh
```

3. **Verify Deployment**:

```bash
kubectl get pods
kubectl get services
```

4. **Access the Application**:

```bash
minikube service nginx
```

## Cleanup

To stop Minikube:

```bash
minikube stop
```

To delete the Minikube cluster entirely:

```bash
minikube delete
```
