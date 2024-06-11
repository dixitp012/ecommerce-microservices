#!/bin/bash

# Check if a service name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <service-name>"
  exit 1
fi

SERVICE_NAME=$1

# Function to get the pod name by app label
get_pod_by_label() {
  local label=$1
  kubectl get pods -l app=$label --no-headers -o custom-columns=":metadata.name" | head -n 1
}

# Function to check if the pod is ready
is_pod_ready() {
  local pod_name=$1
  local status=$(kubectl get pod $pod_name -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}')
  if [ "$status" == "True" ]; then
    return 0
  else
    return 1
  fi
}

# Function to run rails db:create and db:migrate on a pod
run_migrations() {
  local pod_name=$1
  echo "Running migrations on pod: $pod_name"
  kubectl exec -it $pod_name -- /bin/sh -c "bundle exec rails db:create && bundle exec rails db:migrate"
}

# Get the pod for the specified service
echo "Getting pod for service: $SERVICE_NAME"
pod=$(get_pod_by_label "$SERVICE_NAME")
echo "$pod"

# Check if the pod is found
if [ -n "$pod" ]; then
  # Wait until the pod is ready
  while ! is_pod_ready $pod; do
    echo "Pod $pod is not ready yet. Waiting for 10 seconds..."
    sleep 10
  done

  # Run migrations when the pod is ready
  run_migrations $pod
else
  echo "No pod found for service: $SERVICE_NAME"
fi
