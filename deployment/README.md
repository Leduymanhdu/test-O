# Cấu hình triển khai

## 📁 Cấu trúc thư mục

```
deployment/
├── docker/                 # Cấu hình Docker
│   ├── backend/           # Dockerfile Backend
│   ├── frontend/          # Dockerfile Frontend
│   └── docker-compose.yml # Thiết lập Docker Compose
├── kubernetes/            # Kubernetes manifests
│   ├── backend/          # Tài nguyên K8s Backend
│   ├── frontend/         # Tài nguyên K8s Frontend
│   ├── database/         # Tài nguyên Database
│   └── ingress/          # Cấu hình Ingress
├── aws/                  # Triển khai AWS
│   ├── terraform/        # Infrastructure as Code
│   ├── cloudformation/   # CloudFormation templates
│   └── scripts/          # Scripts AWS CLI
├── nginx/                # Cấu hình Nginx
│   ├── nginx.conf       # Cấu hình chính
│   └── sites/           # Cấu hình virtual host
└── scripts/              # Scripts triển khai
    ├── deploy.sh        # Script triển khai chính
    ├── rollback.sh      # Script rollback
    └── health-check.sh  # Script kiểm tra sức khỏe
```

## 🐳 Triển khai Docker

### Môi trường development

```bash
cd deployment/docker
docker-compose up -d
```

### Môi trường production

```bash
# Build images
docker-compose -f docker-compose.prod.yml build

# Triển khai
docker-compose -f docker-compose.prod.yml up -d
```

## ☸️ Triển khai Kubernetes

```bash
# Áp dụng cấu hình
kubectl apply -f kubernetes/

# Kiểm tra trạng thái
kubectl get pods
kubectl get services

# Scale deployment
kubectl scale deployment labodc-backend --replicas=3
```

## ☁️ Triển khai AWS

### Sử dụng Terraform

```bash
cd aws/terraform
terraform init
terraform plan
terraform apply
```

### Các dịch vụ sử dụng
- **EC2**: Máy chủ ứng dụng
- **RDS**: PostgreSQL database
- **ElastiCache**: Redis cache
- **S3**: Tài sản tĩnh và backups
- **CloudFront**: CDN
- **Route53**: Quản lý DNS
- **ELB**: Cân bằng tải
- **ECS/EKS**: Điều phối container

## 🔄 CI/CD Pipeline

### GitLab CI / GitHub Actions

```yaml
stages:
  - test
  - build
  - deploy

test:
  stage: test
  script:
    - npm test
    - mvn test

build:
  stage: build
  script:
    - docker build -t labodc-backend:latest ./labodc-backend
    - docker build -t labodc-frontend:latest ./labodc-web-portal

deploy:
  stage: deploy
  script:
    - ./deployment/scripts/deploy.sh
  only:
    - main
```

## 🔒 Bảo mật

- Chứng chỉ SSL/TLS (Let's Encrypt)
- Xác thực JWT
- Giới hạn tốc độ API
- Mã hóa database
- Quản lý biến môi trường
- Quản lý secrets (AWS Secrets Manager)

## 📊 Giám sát

- **Ứng dụng**: Spring Boot Actuator
- **Hạ tầng**: AWS CloudWatch
- **Logs**: ELK Stack (Elasticsearch, Logstash, Kibana)
- **APM**: New Relic / Datadog
- **Uptime**: Pingdom / UptimeRobot

## 🚨 Sao lưu và khôi phục

- Sao lưu database: Tự động hàng ngày
- Sao lưu ứng dụng: Hàng tuần
- Thời gian lưu trữ: 30 ngày
- Mục tiêu thời gian khôi phục (RTO): < 1 giờ
- Mục tiêu điểm khôi phục (RPO): < 15 phút

## 📝 Kiểm tra sức khỏe

```bash
# Backend health
curl http://localhost:8080/actuator/health

# Frontend health
curl http://localhost:3000/health

# Database health
pg_isready -h localhost -p 5432
```
