#!/bin/bash

# Deploy Flask Microservices to AKS
echo "Deploying Flask Microservices to AKS cluster..."

# Apply namespace first
echo "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Apply ConfigMap
echo "Creating ConfigMap..."
kubectl apply -f k8s/configmap.yaml

# Apply Deployment
echo "Creating Deployment..."
kubectl apply -f k8s/deployment.yaml

# Apply Service (LoadBalancer)
echo "Creating LoadBalancer Service..."
kubectl apply -f k8s/service.yaml

echo "Deployment complete!"
echo ""
echo "Checking deployment status..."
kubectl get pods -n microservices
echo ""
echo "Checking service status..."
kubectl get services -n microservices
echo ""
echo "To get the external IP address, run:"
echo "kubectl get service flask-microservices-service -n microservices --watch"