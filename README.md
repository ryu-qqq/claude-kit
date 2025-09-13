# 🚀 Claude Global Config

**포괄적인 팀 개발 컨벤션과 워크플로우 자동화를 위한 전역 Claude Code 설정**

## 📋 왜 이 설정이 필요한가?

Java 프로젝트마다 다른 컨벤션, 매번 반복되는 설정, 일관성 없는 코드 품질, 안전하지 않은 브랜치 관리...
이 모든 문제를 한 번의 설정으로 해결합니다.

## 🎯 핵심 기능

### 🏗️ Java 21 헥사고날 아키텍처
- 📐 **Java 21 + 헥사고날 아키텍처 완전 가이드**
- 🔍 **ArchUnit 자동 검증** (의존성 방향, 네이밍 규칙)
- 🚫 **Deprecated API 사용 금지** (Java 21 기준)
- ✅ **Record 패턴 강제, Lombok 금지**
- 🎯 **트랜잭션 전략 및 예외 처리 컨벤션**

### 💾 데이터베이스 & 영속성
- 🗃️ **JPA 엔티티 설계 패턴**
- 🔍 **QueryDSL 타입 안전 쿼리**
- ⚡ **캐싱 전략** (Redis, Caffeine)
- 🔄 **애그리게이트 경계 관리**

### 🌐 인프라스트럭처 & DevOps
- 🏗️ **Terraform + Atlantis GitOps 워크플로우**
- ☁️ **3단계 배포 파이프라인** (develop → staging → production)
- 💰 **비용 모니터링 및 안전 장치**
- 📊 **Slack 통합 알림 시스템**

### 🛡️ Git 브랜치 보호 시스템
- 🔒 **main/develop 브랜치 자동 보호**
- 🌿 **Feature 브랜치 강제 워크플로우**
- 🤖 **Claude Code 안전 작업 가이드**
- ✅ **PR 기반 코드 리뷰 프로세스**

### 🤖 SuperClaude 프레임워크
- 🎯 **29개 전문 에이전트** (Backend, Frontend, DevOps 등)
- 🔄 **Wave 오케스트레이션 시스템**
- 📊 **지능형 라우팅 및 도구 선택**
- 🚀 **커스텀 라이브러리 전용 에이전트**

### 🏗️ 커스텀 라이브러리 지원
- 🔧 **StackKit Terraform 전문가** - [StackKit GitHub](https://github.com/ryu-qqq/stack-kit)
- ☁️ **AWS Kit Spring Boot 전문가** - [AWS Kit GitHub](https://github.com/ryu-qqq/aws-kit)

## 🚀 빠른 시작

### 1. 저장소 클론

```bash
git clone https://github.com/ryu-qqq/claude-global-config
cd claude-global-config
```

### 2. 팀 설정 적용

```bash
./setup-team-claude.sh
```

### 3. Git 브랜치 보호 시스템 설치

```bash
./scripts/setup-git-protection.sh
```

### 4. Claude Code 재시작

설정이 적용되도록 Claude Code를 완전히 종료했다가 다시 시작하세요.

## 📋 주요 컨벤션 가이드

### Java 개발 컨벤션

#### 필수 검증 항목
```
✅ Java 21 설정 및 최신 기능 활용
✅ 헥사고날 아키텍처 구조 준수
✅ UseCase/Port/Service 네이밍 규칙
✅ Record 패턴 사용 (Command/Query/Event)
✅ Lombok 사용 금지
✅ Deprecated API 사용 금지
✅ 메서드 레벨 트랜잭션 관리
✅ 도메인 계층 Spring 의존성 금지
```

#### 사용 가능한 명령어
```bash
# Java CI/CD 검증
/husky-java                    # 전체 검증 실행
/husky-java --only-archunit    # 아키텍처만 검증
/husky-java --auto-fix         # 자동 수정 포함
/husky-java --skip-tests       # 테스트 제외
```

### Git 워크플로우

#### 안전한 작업 시작
```bash
# Claude Code 작업 전 필수 실행
./scripts/claude-start-work.sh

# 작업 완료 후 PR 준비
./scripts/claude-prepare-pr.sh
```

#### 브랜치 네이밍 규칙
```bash
feature/TICKET-123-implement-user-auth
bugfix/ORDER-456-fix-payment-timeout
hotfix/CRITICAL-789-security-patch
docs/update-api-documentation
```

### 인프라스트럭처 개발

#### Terraform + Atlantis 워크플로우
```bash
# 1. Feature 브랜치 생성
git checkout -b feature/infra-database-setup

# 2. Terraform 코드 작성
# 3. PR 생성 → Atlantis가 자동으로 plan 실행
# 4. 리뷰 및 승인
# 5. atlantis apply 명령으로 배포
```

#### 환경별 배포 전략
- **develop**: 자동 plan, 수동 apply
- **staging**: plan + 1명 승인 필요
- **production**: plan + 2명 승인 + 보안 검토

## 📁 프로젝트 구조

```
claude-global-config/
├── .claude/                           # Claude Code 설정
│   ├── CLAUDE.md                     # 📌 메인 엔트리 포인트
│   │
│   ├── 🏗️ Java/Spring 컨벤션
│   ├── JAVA_HEXAGONAL.md             # 헥사고날 아키텍처 가이드
│   ├── JAVA_PERSISTENCE.md           # JPA/QueryDSL 패턴
│   ├── JAVA_AGGREGATE_BOUNDARY.md    # DDD 애그리게이트 경계
│   ├── JAVA_VALIDATION.md            # 코드 검증 및 Git 워크플로우
│   │
│   ├── 🌐 인프라 & DevOps
│   ├── INFRA_DEVELOPMENT_FLOW.md     # Terraform/Atlantis GitOps
│   ├── GIT_BRANCH_STRATEGY.md        # 브랜치 전략 및 보호 시스템
│   │
│   ├── 🤖 SuperClaude 프레임워크
│   ├── COMMANDS.MD                   # 명령어 시스템
│   ├── FLAGS.MD                      # 플래그 시스템
│   ├── PERSONAS.MD                   # 전문 페르소나
│   ├── ORCHESTRATOR.MD               # 지능형 라우팅
│   ├── MCP.MD                        # MCP 서버 통합
│   ├── MODES.MD                      # 운영 모드
│   ├── PRINCIPLES.MD                 # 핵심 원칙
│   ├── RULES.MD                      # 행동 규칙
│   │
│   ├── 🔧 커스텀 라이브러리 전문가
│   ├── agents/
│   │   ├── stackkit-terraform-specialist.md  # StackKit 전문가
│   │   └── aws-kit-specialist.md             # AWS Kit 전문가
│   │
│   └── commands/                     # 커스텀 명령어
│       └── husky-java.md            # Java CI/CD 자동화
│
├── scripts/                          # 🛠️ 자동화 도구
│   ├── setup-git-protection.sh      # Git 브랜치 보호 설정
│   ├── claude-start-work.sh          # 안전한 작업 시작
│   └── claude-prepare-pr.sh          # PR 준비 도움
│
├── .devcontainer/                    # 🐳 테스트 환경
└── setup-team-claude.sh             # 📦 원클릭 설정
```

## 🛠️ 자동화 도구 사용법

### Git 브랜치 보호 시스템

```bash
# 초기 설정 (한 번만 실행)
./scripts/setup-git-protection.sh

# Claude Code 작업 전 안전 확인
./scripts/claude-start-work.sh

# 작업 완료 후 PR 준비
./scripts/claude-prepare-pr.sh
```

### 보호 기능
- ✅ main/develop 브랜치 직접 커밋 차단
- ✅ main/develop 브랜치 직접 푸시 차단
- ✅ Feature 브랜치 네이밍 규칙 검증
- ✅ Claude Code 작업 전 브랜치 상태 확인

## 🎯 실제 사용 시나리오

### 🔧 새 기능 개발
```bash
# 1. 안전한 작업 환경 준비
./scripts/claude-start-work.sh

# 2. Feature 브랜치 생성 (가이드에 따라)
git checkout -b feature/USER-123-implement-auth

# 3. Claude Code에게 작업 요청
# "JWT 인증 시스템을 헥사고날 아키텍처로 구현해줘"

# 4. PR 준비
./scripts/claude-prepare-pr.sh

# 5. GitHub에서 PR 생성 및 리뷰
```

### 🏗️ 인프라 구축
```bash
# 1. StackKit 기반 인프라 설계
# "StackKit으로 개발 환경 인프라를 구축해줘"

# 2. Terraform 코드 작성 및 검증
# 3. Atlantis를 통한 안전한 배포
# 4. 환경별 단계적 롤아웃
```

### 🗃️ 데이터베이스 설계
```bash
# 1. JPA 엔티티 및 QueryDSL 설정
# "주문 도메인을 JPA와 QueryDSL로 구현해줘"

# 2. 애그리게이트 경계 설계
# 3. 캐싱 전략 적용
# 4. 성능 최적화
```

## 🐳 DevContainer - Claude Code 실험 공간

Claude Code를 마음껏 테스트할 수 있는 격리된 개발 환경입니다.

### 포함된 도구들
- Java 21 + Spring Boot 3.3
- MySQL 8.4.5 데이터베이스
- AWS LocalStack (로컬 AWS 시뮬레이션)
- Terraform 1.7.5

### DevContainer 사용법

```bash
# VS Code에서 사용
1. VS Code에서 프로젝트 열기
2. Command Palette (Cmd/Ctrl + Shift + P)
3. "Dev Containers: Reopen in Container" 선택

# Docker Compose로 직접 실행
cd .devcontainer
docker-compose up -d
```

이 환경에서 Claude Code의 다양한 기능을 안전하게 테스트해보세요!

## 🎓 학습 리소스

### 문서별 학습 순서

#### 1️⃣ 기초 설정
- [setup-team-claude.sh](./setup-team-claude.sh) - 초기 설정 이해
- [GIT_BRANCH_STRATEGY.md](./.claude/GIT_BRANCH_STRATEGY.md) - 안전한 Git 워크플로우

#### 2️⃣ Java 개발
- [JAVA_HEXAGONAL.md](./.claude/JAVA_HEXAGONAL.md) - 헥사고날 아키텍처 마스터
- [JAVA_PERSISTENCE.md](./.claude/JAVA_PERSISTENCE.md) - 데이터베이스 패턴
- [JAVA_AGGREGATE_BOUNDARY.md](./.claude/JAVA_AGGREGATE_BOUNDARY.md) - DDD 경계 관리

#### 3️⃣ 인프라 & DevOps
- [INFRA_DEVELOPMENT_FLOW.md](./.claude/INFRA_DEVELOPMENT_FLOW.md) - GitOps 마스터
- [agents/stackkit-terraform-specialist.md](./.claude/agents/stackkit-terraform-specialist.md) - StackKit 활용

#### 4️⃣ 고급 활용
- [COMMANDS.MD](./.claude/COMMANDS.MD) - SuperClaude 명령어 시스템
- [PERSONAS.MD](./.claude/PERSONAS.MD) - 전문 에이전트 활용

## 🔄 업데이트

최신 버전을 받으려면:

```bash
git pull origin main
./setup-team-claude.sh
./scripts/setup-git-protection.sh  # Git 보호 시스템 재설정
```

## 📊 팀 혜택

### 개발 속도 향상
- ⚡ **50% 빠른 설정**: 프로젝트별 반복 설정 제거
- 🤖 **자동화된 검증**: 수동 코드 리뷰 시간 단축
- 🛡️ **안전한 워크플로우**: 실수로 인한 롤백 시간 제거

### 코드 품질 보장
- 📐 **일관된 아키텍처**: 팀 전체 동일한 패턴 적용
- 🔍 **자동 검증**: ArchUnit + Git hooks로 품질 보장
- 📚 **명확한 가이드**: 새로운 팀원도 빠른 적응

### 운영 안정성
- 🏗️ **표준화된 인프라**: Terraform + Atlantis로 안전한 배포
- 🔒 **브랜치 보호**: 실수로 인한 프로덕션 장애 방지
- 📊 **모니터링 통합**: Slack 알림으로 실시간 상황 파악

## 🤝 기여

팀 컨벤션과 가이드라인은 실제 사용 경험을 바탕으로 지속적으로 개선됩니다.

### 기여 방법
1. Feature 브랜치 생성
2. 컨벤션 개선사항 추가
3. 실제 프로젝트에서 검증
4. PR 생성 및 팀 리뷰

## 📝 라이센스

내부 사용 목적