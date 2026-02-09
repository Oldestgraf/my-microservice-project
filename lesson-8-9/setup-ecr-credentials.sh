#!/bin/bash

# Setup ECR credentials for Jenkins Kaniko builds
# This script creates a Kubernetes secret with ECR authentication

set -e

# Configuration
AWS_REGION=${AWS_REGION:-"us-west-2"}
ECR_REGISTRY=${ECR_REGISTRY:-"639747620745.dkr.ecr.us-west-2.amazonaws.com"}
NAMESPACE=${NAMESPACE:-"jenkins"}
SECRET_NAME=${SECRET_NAME:-"ecr-credentials"}

echo "=== Setting up ECR credentials for Jenkins ==="
echo "Region: $AWS_REGION"
echo "Registry: $ECR_REGISTRY"
echo "Namespace: $NAMESPACE"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if aws CLI is available
if ! command -v aws &> /dev/null; then
    echo "Error: aws CLI is not installed or not in PATH"
    exit 1
fi

# Check if namespace exists
if ! kubectl get namespace $NAMESPACE &> /dev/null; then
    echo "Error: Namespace $NAMESPACE does not exist"
    echo "Creating namespace..."
    kubectl create namespace $NAMESPACE
fi

# Get ECR login token
echo "Getting ECR login token..."
ECR_PASSWORD=$(aws ecr get-login-password --region $AWS_REGION)

if [ -z "$ECR_PASSWORD" ]; then
    echo "Error: Failed to get ECR login token"
    exit 1
fi

# Create temporary directory for config
TMP_DIR=$(mktemp -d)
CONFIG_FILE="$TMP_DIR/config.json"

# Create Docker config.json
echo "Creating Docker config..."
cat > "$CONFIG_FILE" <<EOF
{
  "auths": {
    "$ECR_REGISTRY": {
      "auth": "$(echo -n AWS:$ECR_PASSWORD | base64)"
    }
  }
}
EOF

# Delete existing secret if it exists
if kubectl get secret $SECRET_NAME -n $NAMESPACE &> /dev/null; then
    echo "Deleting existing secret $SECRET_NAME..."
    kubectl delete secret $SECRET_NAME -n $NAMESPACE
fi

# Create Kubernetes secret
echo "Creating Kubernetes secret..."
kubectl create secret generic $SECRET_NAME \
    --from-file=config.json=$CONFIG_FILE \
    -n $NAMESPACE

# Verify secret creation
if kubectl get secret $SECRET_NAME -n $NAMESPACE &> /dev/null; then
    echo ""
    echo "✓ Secret $SECRET_NAME created successfully in namespace $NAMESPACE"
    echo ""
    echo "Secret details:"
    kubectl describe secret $SECRET_NAME -n $NAMESPACE
else
    echo "Error: Failed to create secret"
    exit 1
fi

# Cleanup
rm -rf "$TMP_DIR"

echo ""
echo "=== Setup complete ==="
echo ""
echo "NOTE: ECR tokens expire after 12 hours."
echo "You may need to run this script again to refresh the credentials."
echo ""
echo "To automate this, consider:"
echo "1. Using IAM roles for service accounts (IRSA)"
echo "2. Setting up a CronJob to refresh credentials periodically"