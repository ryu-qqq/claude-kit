# 🐳 Development Container Environment

완전한 Java Spring Boot + AWS LocalStack 개발 환경을 제공하는 devcontainer 설정입니다.

## 🏗️ 구성 요소

### 컨테이너 서비스

| 서비스 | 포트 | 용도 | 상태 |
|--------|------|------|------|
| **devcontainer** | 8080, 3000, 5001 | 메인 개발 컨테이너 | 항상 실행 |
| **mysql** | 3306 | MySQL 8.0 데이터베이스 | 항상 실행 |
| **localstack** | 4566 | AWS 로컬 시뮬레이션 | 항상 실행 |
| **redis** | 6379 | Redis 캐시 | 선택적 (`--profile cache`) |

### 개발 도구 버전

- **Java**: OpenJDK 21
- **Gradle**: 8.5  
- **Terraform**: 1.7.5
- **Spring Boot**: 3.3 (프로젝트에서 설정)
- **MySQL**: 8.0
- **LocalStack**: 3.0

## 📁 파일 구조 및 역할

```
.devcontainer/
├── README.md                    # 📖 이 파일 - 환경 설명서
├── devcontainer.json           # 🔧 VS Code devcontainer 설정
├── docker-compose.yml          # 🐳 멀티 컨테이너 구성 정의
├── Dockerfile                  # 🏗️ 메인 개발 컨테이너 이미지
├── init-firewall.sh           # 🔥 네트워크 방화벽 설정 스크립트
├── setup-dev-env.sh           # ⚙️ 개발 환경 초기 설정 스크립트
└── scripts/
    ├── init-localstack.sh      # 🚀 LocalStack AWS 리소스 초기화
    └── test-connections.sh     # 🧪 서비스 연결 테스트 스크립트
```

### 상세 파일 설명

#### 🔧 `devcontainer.json`
- **역할**: VS Code devcontainer 확장 설정
- **내용**: 컨테이너 실행 방법, 확장 프로그램, 설정 정의
- **주요 기능**: Java 개발 확장, Git 설정, 터미널 설정

#### 🐳 `docker-compose.yml` 
- **역할**: 멀티 컨테이너 개발 환경 정의
- **내용**: 개발 컨테이너, MySQL, LocalStack, Redis 설정
- **주요 기능**: 서비스 간 네트워킹, 볼륨 마운트, 환경 변수

#### 🏗️ `Dockerfile`
- **역할**: 메인 개발 컨테이너 이미지 빌드
- **내용**: Java, Gradle, Terraform, AWS CLI 설치
- **주요 기능**: 개발 도구 설치, 사용자 계정 설정, 권한 구성

#### 🔥 `init-firewall.sh`
- **역할**: Docker 네트워크와 로컬 방화벽 설정
- **내용**: iptables 규칙 설정으로 보안 강화
- **주요 기능**: 컨테이너 간 통신 허용, 외부 접근 제어

#### ⚙️ `setup-dev-env.sh`
- **역할**: 개발 환경 초기 설정 및 확인
- **내용**: 도구 버전 확인, 서비스 연결 테스트, 환경 구성
- **주요 기능**: 개발 환경 검증, 초기 데이터 설정

#### 🚀 `scripts/init-localstack.sh`
- **역할**: LocalStack AWS 리소스 초기화
- **내용**: S3, DynamoDB, SQS, SNS, Secrets Manager 등 생성
- **주요 기능**: 
  - S3 버킷 3개 생성 (app-bucket, uploads, backups)
  - DynamoDB 테이블 2개 (Users, Products)
  - SQS 큐 3개 (notifications, tasks, tasks-dlq)
  - SNS 토픽, Secrets, CloudWatch Logs, SSM 파라미터

#### 🧪 `scripts/test-connections.sh`
- **역할**: 모든 서비스 연결 상태 테스트
- **내용**: MySQL, LocalStack, Redis 연결 확인
- **주요 기능**: 개발 환경 준비 상태 검증

## 🚀 사용법

### 1. 환경 시작

```bash
# VS Code에서 devcontainer 열기
1. Command Palette (Cmd/Ctrl + Shift + P)
2. "Dev Containers: Reopen in Container" 선택
3. 자동으로 모든 서비스 시작됨

# 또는 Docker Compose로 직접 시작
cd .devcontainer
docker-compose up -d
```

### 2. 서비스 확인

```bash
# 모든 서비스 연결 테스트
./scripts/test-connections.sh

# 개별 서비스 확인
mysql -hmysql -udevuser -pdevpass -e "SHOW DATABASES;"
aws s3 ls --endpoint-url=http://localstack:4566
curl http://localstack:4566/_localstack/health
```

### 3. LocalStack 초기화

```bash
# AWS 리소스 생성 (컨테이너 내부에서)
./scripts/init-localstack.sh

# 생성된 리소스 확인
aws s3 ls --endpoint-url=http://localhost:4566
aws dynamodb list-tables --endpoint-url=http://localhost:4566
```

## 🔧 환경 변수

### 개발 컨테이너
```bash
# Database
MYSQL_HOST=mysql
MYSQL_USER=devuser
MYSQL_PASSWORD=devpass
MYSQL_DATABASE=devdb

# AWS LocalStack
AWS_ENDPOINT_URL=http://localstack:4566
AWS_REGION=ap-northeast-2
LOCALSTACK_HOST=localstack

# Development
JAVA_HOME=/opt/java/openjdk
SPRING_PROFILES_ACTIVE=dev
TZ=Asia/Seoul
```

### LocalStack 서비스
LocalStack에서 제공하는 AWS 서비스:
- **S3**: 객체 스토리지
- **DynamoDB**: NoSQL 데이터베이스
- **Lambda**: 서버리스 함수
- **SQS**: 메시지 큐
- **SNS**: 알림 서비스
- **SES**: 이메일 서비스
- **Secrets Manager**: 비밀 관리
- **SSM**: 파라미터 스토어
- **CloudFormation**: 인프라 템플릿
- **IAM**: 권한 관리
- **CloudWatch Logs**: 로그 관리

## 📊 포트 매핑

```yaml
Host → Container:
  3306 → 3306   # MySQL database
  4566 → 4566   # LocalStack gateway
  6379 → 6379   # Redis cache (optional)
  8080 → 8080   # Spring Boot app
  3000 → 3000   # Frontend dev server
  5001 → 5000   # Additional services
```

## 🔍 트러블슈팅

### 컨테이너가 시작되지 않는 경우

```bash
# 컨테이너 로그 확인
docker-compose logs devcontainer
docker-compose logs mysql
docker-compose logs localstack

# 컨테이너 재시작
docker-compose restart
```

### MySQL 연결 오류

```bash
# MySQL 상태 확인
docker-compose exec mysql mysqladmin ping -uroot -prootpass

# 수동 연결 테스트
docker-compose exec devcontainer mysql -hmysql -udevuser -pdevpass
```

### LocalStack 연결 오류

```bash
# LocalStack 상태 확인
curl http://localhost:4566/_localstack/health

# 서비스별 상태 확인
aws s3 ls --endpoint-url=http://localhost:4566
aws dynamodb list-tables --endpoint-url=http://localhost:4566
```

### 권한 문제

```bash
# 파일 권한 수정
sudo chown -R $(whoami):$(whoami) ~/.aws ~/.ssh

# 스크립트 실행 권한
chmod +x .devcontainer/scripts/*.sh
```

## 🎯 개발 워크플로우

### 1. 프로젝트 시작
```bash
# Spring Boot 프로젝트 생성
./create-spring-app.sh my-app

# Terraform 프로젝트 생성  
./create-terraform-project.sh my-infrastructure
```

### 2. 데이터베이스 작업
```bash
# MySQL 연결
mysql -hmysql -udevuser -pdevpass devdb

# 데이터베이스 마이그레이션
./gradlew flywayMigrate
```

### 3. AWS 서비스 개발
```bash
# LocalStack 리소스 초기화
./scripts/init-localstack.sh

# S3 업로드 테스트
aws s3 cp test-file.txt s3://dev-app-bucket/ --endpoint-url=http://localhost:4566

# DynamoDB 쿼리 테스트
aws dynamodb scan --table-name Users --endpoint-url=http://localhost:4566
```

### 4. 애플리케이션 실행
```bash
# Spring Boot 애플리케이션 시작
./gradlew bootRun

# 애플리케이션 접근: http://localhost:8080
```

## ✨ 추가 기능

### Redis 캐시 활성화
```bash
# Redis 서비스 시작
docker-compose --profile cache up -d redis

# Redis 연결 테스트
redis-cli -h localhost ping
```

### 성능 모니터링
```bash
# 컨테이너 리소스 사용량
docker stats

# 로그 모니터링
docker-compose logs -f devcontainer
```

---

**💡 참고**: 이 devcontainer는 순수 개발 환경만 제공합니다. Claude Code 관련 설정은 프로젝트 루트의 `setup-team-claude.sh`를 사용하세요.