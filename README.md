# Project: Operationalizing a Coworking Space Microservice

## Overview
The Coworking Space Service API enables users to request one-time tokens and allows administrators to authorize access to coworking spaces. Following a microservice architecture, this service is deployed and managed independently within a Kubernetes environment. This project focuses on deploying an analytics API that provides business analysts with basic user activity data.

## Dependencies
### Local Environment
- **Python Environment:** Python 3.6+ for running applications and managing dependencies via `pip`.
- **Docker CLI:** Required for building and testing Docker images locally.
- **kubectl:** Essential for interacting with the Kubernetes cluster.
- **helm:** Used for deploying the PostgreSQL database via Helm Charts.

### Remote Resources
- **AWS CodeBuild:** To build Docker images remotely.
- **AWS ECR:** To store Docker images.
- **AWS EKS:** To deploy and manage Kubernetes clusters.
- **AWS CloudWatch:** For monitoring application logs and metrics.
- **GitHub:** For version control and source code management.

### Setup

#### 1. Configure the Database

To set up a PostgreSQL database in your Kubernetes cluster, follow these steps:

1. **Add the Bitnami Helm Repository:**
   ```bash
   helm repo add <REPO_NAME> https://charts.bitnami.com/bitnami
   ```

2. **Install the PostgreSQL Helm Chart:**
   ```bash
   helm install <SERVICE_NAME> <REPO_NAME>/postgresql
   ```

   This will deploy a PostgreSQL instance at `<SERVICE_NAME>-postgresql.default.svc.cluster.local` within your Kubernetes cluster. You can verify the deployment by running:
   ```bash
   kubectl get svc
   ```

   By default, this setup will create a `postgres` user. You can retrieve the password with the following command:
   ```bash
   export POSTGRES_PASSWORD=$(kubectl get secret --namespace default <SERVICE_NAME>-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
   echo $POSTGRES_PASSWORD
   ```

   *(These instructions are adapted from Bitnami's PostgreSQL Helm Chart.)*

3. **Test Database Connection:**
   The database is accessible within the Kubernetes cluster, but connecting from your local environment may require additional steps. You can either connect via a pod within the cluster or use port forwarding.

   - **Connecting Via Port Forwarding:**
     ```bash
     kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
     PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432
     ```

   - **Connecting Via a Pod:**
     ```bash
     kubectl exec -it <POD_NAME> bash
     PGPASSWORD="<PASSWORD HERE>" psql postgres://postgres@<SERVICE_NAME>:5432/postgres -c <COMMAND_HERE>
     ```

4. **Run Seed Files:**
   To set up the necessary tables and data, run the seed files located in the `db/` directory:
   ```bash
   kubectl port-forward --namespace default svc/<SERVICE_NAME>-postgresql 5432:5432 &
   PGPASSWORD="$POSTGRES_PASSWORD" psql --host 127.0.0.1 -U postgres -d postgres -p 5432 < <FILE_NAME.sql>
   ```


## Deployment Process
1. **Database Setup:** A PostgreSQL database is deployed in the Kubernetes cluster using a Helm Chart. The database is initialized with seed data to support the application.
2. **Dockerization:** The Python-based analytics application is containerized using a Dockerfile. This image is built and pushed to AWS ECR using a CI/CD pipeline configured in AWS CodeBuild.
3. **Kubernetes Deployment:** The application is deployed using Kubernetes configurations that define services, deployments, and ConfigMaps. These configurations ensure the application is scalable and resilient.
4. **Monitoring:** AWS CloudWatch is utilized for monitoring logs and performance metrics, ensuring the application operates smoothly.

## Key Deliverables
- **Dockerfile:** Configured to use a Python base image and optimized for the application.
- **Build Pipeline:** A CodeBuild pipeline that builds the Docker image and pushes it to ECR.
- **Kubernetes Configurations:** YAML files for deploying the application in EKS.
- **Monitoring:** Application logs and metrics available in CloudWatch for tracking performance and issues.

## Stand Out Suggestions
1. **Memory and CPU Allocation:** Reasonable memory and CPU allocations are specified in the Kubernetes deployment files to optimize resource usage and ensure application stability.
2. **AWS Instance Type Recommendation:** For this application, an `m5.large` instance type is recommended due to its balanced compute, memory, and network performance, which is suitable for running microservices like the analytics API.
3. **Cost Savings Consideration:** To save on costs, consider using spot instances in non-critical environments, reducing the size of the Kubernetes cluster during off-peak hours, and optimizing the Docker image to reduce build times and storage costs.
