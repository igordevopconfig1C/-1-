#!/bin/bash
set -e
kind delete cluster 2>/dev/null || true
kind create cluster
docker build -t mini-headhunter:latest .
kind load docker-image mini-headhunter:latest
kubectl create configmap db-init --from-file=schema.sql
kubectl apply -f k8s.yaml
kubectl rollout status deploy/mini-headhunter --timeout=180s
echo "Готово. Запустите: kubectl port-forward svc/mini-headhunter 5000:80"
