# 🚀 Claude Kit

팀 내에서 동일한 Claude Code 개발 환경을 구축하기 위한 설정 모음입니다.

## 📋 프로젝트 소개

이 프로젝트는 **초기 단계**로, 팀원들이 동일한 Claude Code 설정을 공유하여 일관된 개발 경험을 갖도록 돕습니다.

### 현재 제공하는 기능

- ✅ **표준화된 Claude Code 설정** - 팀 전체가 동일한 AI 어시스턴트 환경 사용
- ✅ **자동 승인 설정** - 안전한 명령어들은 확인 없이 자동 실행
- ✅ **DevContainer 테스트 환경** - Claude Code를 마음껏 실험할 수 있는 격리된 공간

## 🎯 빠른 시작

### 1. 저장소 클론

```bash
git clone https://github.com/ryu-qqq/claude-kit.git
cd claude-kit
```

### 2. Claude Code 설정 적용

```bash
./setup-team-claude.sh
```

### 3. Claude Code 재시작

설정이 적용되도록 Claude Code를 완전히 종료했다가 다시 시작하세요.

## 🤖 자동으로 설정되는 것들

### Claude Code 기본 설정
- **SuperClaude 프레임워크** - 향상된 명령어 시스템
- **29개 전문 에이전트** - Spring Boot, AWS, DevOps 등 도메인별 전문가
- **자동 승인 규칙** - 300+ 안전한 명령어 패턴
- **텔레메트리** - Claude Code 사용 패턴 분석 (기본 활성화)

### 자동 승인되는 명령어 예시

```bash
# ✅ 자동 실행 (확인 없음)
ls, cat, grep, git status, git diff
npm test, npm run build, ./gradlew test
docker ps, terraform plan

# ❌ 수동 확인 필요
rm -rf, git push, npm install
terraform apply, docker rm
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
claude-kit/
├── .claude/                  # Claude Code 설정
│   ├── agents/              # 29개 전문 에이전트
│   ├── auto-approval.json   # 자동 승인 설정
│   ├── telemetry.env        # 텔레메트리 설정
│   ├── README.md            # 설정 파일 가이드
│   └── *.MD                 # SuperClaude 프레임워크
├── .devcontainer/           # 테스트용 Docker 환경
└── setup-team-claude.sh     # 원클릭 설정 스크립트
```

### 📚 더 자세한 설정 정보

- **SuperClaude 프레임워크 이해하기**: [.claude/README.md](.claude/README.md)
- **텔레메트리 설정 변경**: `.claude/telemetry.env` 파일 수정
- **자동 승인 규칙 커스터마이징**: `.claude/auto-approval.json` 파일 수정

## 🔄 업데이트

이 프로젝트는 계속 발전하고 있습니다. 최신 버전을 받으려면:

```bash
git pull origin main
./setup-team-claude.sh
```

## 🤝 기여

팀 컨벤션과 가이드라인은 실제 사용 경험을 바탕으로 추가될 예정입니다.

## 📝 라이센스

내부 사용 목적

---

**Repository**: https://github.com/ryu-qqq/claude-kit  
**초기 버전**: 기본 설정 + DevContainer 테스트 환경