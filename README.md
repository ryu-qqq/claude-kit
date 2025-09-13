# 🚀 Claude Global Config

**SuperClaude 프레임워크와 Java 헥사고날 아키텍처를 위한 전역 Claude Code 설정**

## 📋 왜 이 설정이 필요한가?

Java 프로젝트마다 다른 컨벤션, 매번 반복되는 설정, 일관성 없는 코드 품질...
이 모든 문제를 한 번의 설정으로 해결합니다.

## 🎯 핵심 기능

### Java 헥사고날 아키텍처
- 📐 **Java 21 + 헥사고날 아키텍처 컨벤션**
- 🔍 **ArchUnit 자동 검증**
- ✅ **Husky CI/CD 통합**
- 🚫 **Lombok 금지, Record 패턴 강제**

### SuperClaude 프레임워크
- 🤖 **29개 전문 에이전트** (Backend, Frontend, DevOps 등)
- 🎯 **자동화된 명령어 시스템**
- 📊 **지능형 라우팅 시스템**
- 🔄 **Wave 오케스트레이션**

### 커스텀 라이브러리 지원
- 🏗️ **StackKit Terraform 전문가**
- ☁️ **AWS Kit Spring Boot 전문가**

## 🎯 빠른 시작

### 1. 저장소 클론

```bash
git clone https://github.com/ryu-qqq/claude-kit
cd claude-global-config
```

### 2. Claude Code 설정 적용

```bash
./setup-team-claude.sh
```

### 3. Claude Code 재시작

설정이 적용되도록 Claude Code를 완전히 종료했다가 다시 시작하세요.

## 🎯 Java 프로젝트에서 사용

### 사용 가능한 명령어

```bash
# Java CI/CD 검증
/husky-java                    # 전체 검증 실행
/husky-java --only-archunit    # 아키텍처만 검증
/husky-java --auto-fix         # 자동 수정 포함
/husky-java --skip-tests       # 테스트 제외
```

### 자동 검증 항목

```
✅ Java 21 설정 확인
✅ 헥사고날 아키텍처 준수
✅ 네이밍 컨벤션 (UseCase, Port, Service)
✅ Lombok 사용 금지
✅ Record 패턴 사용
✅ 코드 품질 (Checkstyle, PMD, SpotBugs)
✅ 테스트 커버리지 80% 이상
✅ 커밋 메시지 규약
```

## 🐳 DevContainer - Claude Code 실험 공간

Claude Code를 마음껏 테스트할 수 있는 격리된 개발 환경입니다.

### 포함된 도구들
- Java 21 + Spring Boot 3.3
- MySQL 8.0 데이터베이스
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

## 📁 프로젝트 구조

```
claude-global-config/
├── .claude/                  # Claude Code 설정
│   ├── CLAUDE.md            # 엔트리 포인트
│   ├── JAVA_HEXAGONAL.md    # Java 헥사고날 컨벤션
│   ├── JAVA_VALIDATION.md   # 검증 및 Git 워크플로우
│   ├── commands/            # 커스텀 명령어
│   │   └── husky-java.md   # Java CI/CD 자동화
│   ├── agents/             # 전문 에이전트
│   │   ├── stackkit-terraform-specialist.md
│   │   └── aws-kit-specialist.md
│   └── *.MD                # SuperClaude 프레임워크 파일들
├── .devcontainer/          # 테스트용 Docker 환경
└── setup-team-claude.sh    # 원클릭 설정 스크립트
```

### 📚 더 자세한 설정 정보

- **SuperClaude 프레임워크 이해하기**: [.claude/README.md](.claude/README.md)
- **텔레메트리 설정 변경**: `.claude/telemetry.env` 파일 수정
- **자동 승인 규칙 커스터마이징**: `.claude/auto-approval.json` 파일 수정

## 🔄 업데이트

최신 버전을 받으려면:

```bash
git pull origin main
./setup-team-claude.sh
```

## 🤝 기여

팀 컨벤션과 가이드라인은 실제 사용 경험을 바탕으로 추가될 예정입니다.

## 📝 라이센스

내부 사용 목적

---

**Repository**: https://github.com/ryu-qqq/claude-global-config
**현재 버전**: SuperClaude + Java 헥사고날 아키텍처 + 커스텀 라이브러리 지원