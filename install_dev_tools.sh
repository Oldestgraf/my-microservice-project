#!/bin/bash
set -e

echo "Installing Dev Tools"

# Docker
if command -v docker >/dev/null 2>&1; then
  echo "Docker already installed"
else
  echo "Installing Docker..."
  sudo apt update
  sudo apt install -y docker.io
  sudo systemctl enable --now docker
  echo "Docker installed"
fi

# Docker Compose
if docker compose version >/dev/null 2>&1; then
  echo "Docker Compose already installed"
else
  echo "Installing Docker Compose..."
  sudo apt update
  sudo apt install -y docker-compose-plugin
  echo "Docker Compose installed"
fi

# Python 3 + pip
if command -v python3 >/dev/null 2>&1; then
  echo "Python already installed: $(python3 --version)"
else
  echo "Installing Python..."
  sudo apt update
  sudo apt install -y python3 python3-pip
  echo "Python installed"
fi

# Django
if python3 -c "import django" >/dev/null 2>&1; then
  echo "Django already installed"
else
  echo "Installing Django..."
  pip3 install --user django
  echo "Django installed"
fi

echo "Done"
echo "Check:"
echo "docker --version"
echo "docker compose version"
echo "python3 --version"
echo "python3 -m django --version"
