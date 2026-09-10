# Microservices Kubernetes CI/CD Platform

A production-style DevOps portfolio project demonstrating automated testing,
container security, image publishing, Kubernetes deployment, observability,
notifications and automatic rollback.

## Project Architecture

The application contains four Python FastAPI microservices:

- User Service
- Order Service
- Payment Service
- Notification Service

## Technology Stack

- GitHub
- Jenkins
- Python FastAPI
- Pytest
- Docker and Docker Compose
- Trivy
- Terraform
- AWS ECR
- Amazon EKS
- Amazon RDS PostgreSQL
- Helm
- NGINX Ingress
- Istio
- Prometheus
- Grafana
- Centralized logging
- Slack and email notifications

## CI/CD Workflow

1. Check out the source code
2. Install application dependencies
3. Run automated tests
4. Build container images
5. Scan images with Trivy
6. Push approved images to Amazon ECR
7. Deploy the images to Amazon EKS
8. Run post-deployment health checks
9. Roll back automatically when validation fails
10. Send deployment notifications

## Repository Structure

- `services/` - Microservice application code and tests
- `deploy/` - Helm charts and Kubernetes platform configurations
- `infra/` - Terraform infrastructure
- `jenkins/` - Jenkins automation scripts
- `scripts/` - Validation and operational scripts
- `docs/` - Architecture, runbooks and project evidence

## Project Status

Phase 1: Repository initialization