# 인프라 개발 플로우 컨벤션

Terraform + Atlantis를 활용한 안전한 인프라 개발 및 배포 워크플로우 컨벤션입니다.

## 핵심 원칙

1. **단계적 승인**: 환경별로 다른 승인 권한과 프로세스
2. **Plan First**: 모든 변경사항은 계획 단계에서 충분히 검토
3. **Cost Awareness**: 비용 영향을 사전에 분석하고 승인
4. **Safe Deployment**: 운영 환경은 수동 승인 후에만 배포
5. **Rollback Ready**: 모든 배포는 롤백 계획을 포함

## 브랜치 전략

### Git Flow for Infrastructure
```
feature/infra-*        # 인프라 변경 브랜치
  ↓
develop               # Plan Only (비용 검토 + 코드 리뷰)
  ↓
staging               # 실제 Apply (테스트 환경)
  ↓
main/prod             # 수동 승인 후 Apply (운영 환경)
```

### 브랜치 네이밍 컨벤션
```bash
feature/infra-add-rds-cluster      # 새 리소스 추가
feature/infra-update-ec2-size      # 기존 리소스 수정
feature/infra-remove-unused-lb     # 리소스 제거
hotfix/infra-security-patch        # 긴급 보안 패치
```

## Atlantis 워크플로우 설정

### atlantis.yaml 설정
```yaml
version: 3
automerge: false  # 자동 병합 완전 비활성화

projects:
- name: dev-environment
  dir: environments/dev
  workspace: dev
  workflow: dev-workflow

- name: staging-environment
  dir: environments/staging
  workspace: staging
  workflow: staging-workflow

- name: prod-environment
  dir: environments/prod
  workspace: prod
  workflow: prod-workflow

workflows:
  dev-workflow:
    plan:
      enabled: true
      steps:
      - init
      - plan:
          extra_args: ["-var-file=terraform.tfvars"]
      - run: |
          infracost breakdown --path . \
            --terraform-var-file terraform.tfvars \
            --format json --out-file infracost.json
      - run: |
          infracost comment github --path infracost.json \
            --repo $ATLANTIS_REPO_FULL_NAME \
            --pull-request $ATLANTIS_PULL_NUM \
            --github-token $GITHUB_TOKEN
    apply:
      enabled: false  # dev는 plan만 실행

  staging-workflow:
    plan:
      enabled: true
      steps:
      - init
      - plan:
          extra_args: ["-var-file=terraform.tfvars"]
      - run: infracost breakdown --path . --terraform-var-file terraform.tfvars
    apply:
      enabled: true
      requirements: [approved, mergeable]
      steps:
      - init
      - plan:
          extra_args: ["-var-file=terraform.tfvars"]
      - apply

  prod-workflow:
    plan:
      enabled: true
      steps:
      - init
      - plan:
          extra_args: ["-var-file=terraform.tfvars"]
      - run: infracost breakdown --path . --terraform-var-file terraform.tfvars
    apply:
      enabled: true
      requirements: [approved, mergeable]
      steps:
      - init
      - plan:
          extra_args: ["-var-file=terraform.tfvars"]
      - run: echo "⚠️ PRODUCTION DEPLOYMENT - Manual approval required"
      - apply
```

## 환경별 승인 프로세스

### 승인 권한 매트릭스
| 환경 | Plan 권한 | Apply 권한 | 필수 승인 | 추가 요구사항 |
|------|----------|-----------|---------|------------|
| **develop** | 모든 개발자 | ❌ 비활성화 | - | Plan 검토만 |
| **staging** | 모든 개발자 | 시니어 개발자 + DevOps | 1개 이상 | 비용 검토 완료 |
| **production** | 시니어 개발자 이상 | DevOps 팀장 + CTO | 2개 이상 | 모든 검토 항목 완료 |

### 검토 체크리스트

#### Develop (Plan Only)
- [ ] Terraform 문법 검증
- [ ] 리소스 네이밍 컨벤션 준수
- [ ] 태그 정책 준수
- [ ] 보안 그룹 설정 검토
- [ ] 비용 영향 분석 (Infracost)

#### Staging (실제 배포)
- [ ] Develop 단계 모든 검토 완료
- [ ] 백업/복구 계획 수립
- [ ] 모니터링 설정 확인
- [ ] 테스트 계획 수립
- [ ] 롤백 절차 준비

#### Production (최종 배포)
- [ ] Staging 테스트 완료 확인
- [ ] 성능 영향 분석
- [ ] 보안 영향 평가
- [ ] 비즈니스 영향 분석
- [ ] 배포 시간 조율
- [ ] 장애 대응 계획

## 상세 워크플로우

### 1. 인프라 변경 시작
```bash
# 1. 인프라 변경 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b feature/infra-add-redis-cluster

# 2. 브랜치 보호 규칙 확인
# - develop: plan 자동 실행
# - staging/main: 수동 apply만 가능
```

### 2. Terraform 코드 작성
```bash
# 환경별 설정 예시
# environments/dev/redis.tf
module "redis" {
  source = "../../modules/redis"

  cluster_name = "${var.project_name}-${var.environment}-redis"
  node_type    = var.environment == "prod" ? "cache.r6g.large" : "cache.t3.micro"
  num_cache_nodes = var.environment == "prod" ? 3 : 1

  vpc_id     = data.terraform_remote_state.networking.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.networking.outputs.private_subnet_ids

  # 보안 설정
  security_group_ids = [aws_security_group.redis.id]

  # 백업 설정 (production만)
  backup_retention_limit = var.environment == "prod" ? 7 : 0
  backup_window         = var.environment == "prod" ? "03:00-04:00" : null

  tags = merge(var.common_tags, {
    Service = "caching"
    Purpose = "application-cache"
  })
}

# 보안 그룹 설정
resource "aws_security_group" "redis" {
  name_prefix = "${var.project_name}-${var.environment}-redis-"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.app.outputs.app_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
```

### 3. 로컬 검증
```bash
# Terraform 검증
terraform fmt -recursive
terraform validate

# 비용 추정
infracost breakdown --path environments/dev \
  --terraform-var-file environments/dev/terraform.tfvars

# 보안 검사
tfsec environments/dev/
```

### 4. PR 생성 및 자동 검토
```bash
# PR 생성
gh pr create --title "feat(infra): Add Redis cluster for application caching" \
  --body "## 📋 변경사항
- Redis 클러스터 추가 (ElastiCache)
- 환경별 인스턴스 크기 자동 설정
- 보안 그룹 및 네트워크 설정
- 운영환경 백업 설정

## 💰 비용 영향
- **Dev**: ~$15/month (t3.micro, 1 node)
- **Staging**: ~$50/month (t3.small, 1 node)
- **Production**: ~$200/month (r6g.large, 3 nodes)

## 🎯 예상 효과
- 데이터베이스 부하 30% 감소
- API 응답시간 40% 개선
- 사용자 세션 관리 개선

## ✅ 체크리스트
- [x] 로컬 terraform validate 완료
- [x] 보안 검사 (tfsec) 통과
- [x] 비용 분석 완료
- [x] 네이밍 컨벤션 준수
- [x] 태그 정책 적용
- [ ] 팀 리뷰 대기
- [ ] Atlantis plan 검토 대기" \
  --assignee @me \
  --reviewer devops-team,senior-developers

# Atlantis 자동 plan 실행됨 (PR 생성시)
```

### 5. 팀 리뷰 및 승인
```yaml
# 리뷰 포인트
technical_review:
  - Terraform 코드 품질
  - 리소스 설정의 적절성
  - 보안 설정 검토
  - 네이밍 및 태그 컨벤션

business_review:
  - 비용 대비 효과 분석
  - 비즈니스 요구사항 만족도
  - 대안 검토 결과

operational_review:
  - 모니터링 설정
  - 백업/복구 계획
  - 장애 대응 방안
  - 확장성 고려사항
```

### 6. Develop 병합 (Plan 승인)
```bash
# 모든 리뷰 승인 후 병합
gh pr merge --squash

# develop 브랜치에서는 plan만 실행됨
# 실제 인프라 변경 없음 ✅
```

### 7. Staging 환경 배포
```bash
# staging 브랜치로 이동
git checkout staging
git pull origin staging
git merge develop

# staging 환경 수동 배포
# Slack/GitHub에서 수동 명령:
# "atlantis apply staging"

# 배포 완료 후 테스트 실행
./scripts/test-redis-connectivity.sh staging
./scripts/load-test.sh staging
```

### 8. Production 준비 및 승인
```bash
# main 브랜치 준비
git checkout main
git pull origin main
git merge staging

# Production 배포 승인 요청
# Slack 채널에 승인 요청 메시지 자동 발송:
# "🚨 Production Infrastructure Deployment Request
#  - Redis cluster 추가
#  - 비용 영향: +$200/month
#  - 승인 필요: @devops-lead @cto"

# 최종 승인 후 수동 배포
# "atlantis apply production"
```

## 모니터링 및 알림

### Slack 통합 설정
```yaml
# Slack 알림 설정
notifications:
  plan_completed:
    template: |
      📊 **Infrastructure Plan 완료**

      **환경**: {{.Environment}}
      **PR**: {{.PullRequestURL}}
      **비용 변화**: {{.CostDiff}}
      **리소스 변경**: +{{.ResourcesAdded}} -{{.ResourcesRemoved}}

      **다음 단계**: 팀 리뷰 및 승인 대기
    channels: ["#infra-review"]

  apply_requested:
    template: |
      🚨 **{{.Environment}} 배포 승인 필요**

      **변경사항**: {{.Changes}}
      **비용 영향**: {{.CostImpact}}
      **요청자**: {{.Author}}

      **승인 명령**: `atlantis apply {{.Environment}}`
    channels: ["#infra-approvals"]
    mentions:
      staging: ["@devops-team"]
      production: ["@devops-lead", "@cto"]

  apply_completed:
    template: |
      ✅ **Infrastructure 배포 완료**

      **환경**: {{.Environment}}
      **배포 시간**: {{.DeployTime}}
      **적용된 변경사항**: {{.AppliedChanges}}

      **모니터링**: {{.MonitoringLinks}}
    channels: ["#general", "#infra-review"]

  apply_failed:
    template: |
      ❌ **Infrastructure 배포 실패**

      **환경**: {{.Environment}}
      **오류**: {{.Error}}
      **롤백 필요**: 즉시 대응 요망
    channels: ["#incident-response"]
    mentions: ["@devops-oncall"]
```

### 비용 모니터링
```yaml
# AWS Budget 알림 설정
cost_monitoring:
  budget_alerts:
    dev_monthly:
      limit: 100
      threshold: 80  # 80% 도달시 알림

    staging_monthly:
      limit: 300
      threshold: 80

    production_monthly:
      limit: 2000
      threshold: 75  # 더 보수적 임계값

  cost_anomaly_detection:
    enabled: true
    threshold: 150  # 150% 증가시 알림

  daily_cost_report:
    enabled: true
    channels: ["#infra-costs"]
```

## 안전장치 및 제약사항

### 배포 시간 제한
```yaml
deployment_windows:
  staging:
    allowed: "24/7"
    restrictions: []

  production:
    allowed: "Mon-Thu 09:00-17:00 KST"
    blocked_periods:
      - "2024-12-24 ~ 2024-12-26"  # 크리스마스
      - "2024-12-31 ~ 2025-01-02"  # 신정
      - "매월 마지막 금요일"         # 정기 점검일
    emergency_override: true  # 긴급시 승인 후 배포 가능
```

### 리소스 제한
```yaml
resource_limits:
  max_cost_increase_per_pr:
    dev: 50      # $50/month
    staging: 100  # $100/month
    prod: 500    # $500/month

  max_resources_per_pr:
    ec2_instances: 5
    rds_instances: 2
    load_balancers: 3

  required_approvals_by_cost:
    - cost_range: "$0-100/month"
      approvals: 1
    - cost_range: "$100-500/month"
      approvals: 2
    - cost_range: "$500+/month"
      approvals: 3
      additional_requirements: ["business_justification", "cto_approval"]
```

### 자동 롤백 조건
```yaml
auto_rollback_triggers:
  health_check_failure:
    duration: "5 minutes"
    threshold: "3 consecutive failures"

  cost_spike:
    threshold: "200% of baseline"
    duration: "1 hour"

  error_rate_increase:
    threshold: "50% increase"
    duration: "10 minutes"

manual_rollback_procedures:
  staging:
    command: "atlantis apply staging --rollback"
    timeline: "즉시 가능"

  production:
    approval_required: true
    approvers: ["@devops-lead", "@cto"]
    timeline: "승인 후 30분 내"
```

## 트러블슈팅 가이드

### 자주 발생하는 문제들

#### 1. Atlantis Plan 실패
```bash
# 문제: terraform validate 실패
# 해결책:
terraform fmt -recursive
terraform validate

# 문제: 의존성 리소스 없음
# 해결책: remote state 확인
terraform state list
```

#### 2. Apply 권한 오류
```bash
# 문제: 승인 부족
# 해결책: 필요한 승인 획득 후 재시도

# 문제: 배포 시간 제한
# 해결책: 허용 시간대에 재배포 또는 긴급 승인 요청
```

#### 3. 비용 제한 초과
```bash
# 문제: 비용 한도 초과
# 해결책:
# 1. 리소스 크기 조정
# 2. 비즈니스 승인 획득
# 3. 단계적 배포 계획 수립
```

## 체크리스트

### 인프라 변경 전
- [ ] 비즈니스 요구사항 명확화
- [ ] 기술적 대안 검토
- [ ] 비용 영향 분석
- [ ] 보안 영향 평가
- [ ] 롤백 계획 수립

### 코드 작성 시
- [ ] Terraform 문법 검증
- [ ] 보안 설정 검토 (tfsec)
- [ ] 네이밍 컨벤션 준수
- [ ] 태그 정책 적용
- [ ] 환경별 설정 분리

### 배포 전
- [ ] 모든 필수 승인 획득
- [ ] 배포 시간 확인
- [ ] 모니터링 설정 완료
- [ ] 롤백 절차 준비
- [ ] 팀 커뮤니케이션 완료

### 배포 후
- [ ] 서비스 정상 동작 확인
- [ ] 성능 영향 모니터링
- [ ] 비용 변화 추적
- [ ] 문서 업데이트
- [ ] 팀 공유 및 피드백