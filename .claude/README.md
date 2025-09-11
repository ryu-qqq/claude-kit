# 📚 Claude Code 설정 디렉토리

이 디렉토리는 Claude Code의 고급 기능 설정을 담고 있습니다.

## 🔧 텔레메트리 설정 (telemetry.env)

Claude Code의 사용 패턴 분석을 위한 OpenTelemetry 설정입니다.

### 외부 OTEL Collector 사용하기

```bash
# telemetry.env 파일 수정
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_SERVICE_NAME="claude-code"
export OTEL_EXPORTER_OTLP_ENDPOINT=http://your-otel-collector:4317  # 여기를 수정
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_TRACES_EXPORTER=otlp
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
```

### 설정 적용
```bash
source ~/.claude/telemetry.env  # 또는 setup-team-claude.sh 실행
```

## 📖 SuperClaude 프레임워크 파일

### 핵심 설정 파일

#### CLAUDE.md
- **역할**: SuperClaude 프레임워크 진입점
- **내용**: 다른 모든 설정 파일을 로드하는 메인 파일

#### PROJECT.md  
- **역할**: 프로젝트별 기본 가이드라인
- **내용**: 코딩 컨벤션, 재사용 에이전트, 커스텀 훅

### 명령어 시스템

#### COMMANDS.MD
- **역할**: `/analyze`, `/build`, `/implement` 등 슬래시 명령어 정의
- **내용**: 각 명령어의 동작 방식과 자동 활성화 조건

#### FLAGS.MD
- **역할**: `--think`, `--uc`, `--seq` 등 실행 플래그 정의
- **내용**: 분석 깊이, 압축 모드, MCP 서버 제어 플래그

### 동작 원칙

#### PRINCIPLES.MD
- **역할**: 소프트웨어 엔지니어링 원칙
- **내용**: SOLID, DRY, KISS 등 개발 철학과 품질 기준

#### RULES.MD
- **역할**: Claude Code 동작 규칙
- **내용**: 우선순위 시스템, 워크플로우 규칙, 안전 규칙

### 지능형 시스템

#### MCP.MD
- **역할**: Model Context Protocol 서버 통합
- **내용**: Context7, Sequential, Magic 등 서버 활성화 로직

#### PERSONAS.MD
- **역할**: 11개 전문 페르소나 시스템
- **내용**: architect, frontend, backend 등 도메인별 전문가

#### ORCHESTRATOR.MD
- **역할**: 지능형 라우팅 시스템
- **내용**: 복잡도 감지, 자동 도구 선택, 품질 검증

#### MODES.MD
- **역할**: 운영 모드 참조
- **내용**: Task Management, Introspection, Token Efficiency 모드

### 에이전트 관리

#### AGENTS-REGISTRY.md
- **역할**: 29개 전문 에이전트 레지스트리
- **내용**: Spring Boot, AWS, DevOps 등 도메인별 에이전트 목록

#### agents/ 디렉토리
- **역할**: 개별 에이전트 정의 파일들
- **내용**: 각 에이전트의 전문 영역과 도구 사용 패턴

### 자동 승인 설정

#### auto-approval.json
- **역할**: 안전한 명령어 자동 실행 규칙
- **내용**: 300+ 명령어 패턴, 위험도별 분류
- **사용법**: Claude Code가 확인 없이 실행할 수 있는 명령어 정의

## 🚀 설정 적용 방법

```bash
# 1. 전체 설정 적용
./setup-team-claude.sh

# 2. 개별 설정 확인
cat ~/.claude/CLAUDE.md  # 메인 설정
cat ~/.claude/auto-approval.json  # 자동 승인 규칙

# 3. 텔레메트리만 설정
source ~/.claude/telemetry.env
```

## 💡 팁

- **SuperClaude 활성화**: CLAUDE.md가 있으면 자동으로 고급 기능 활성화
- **자동 승인**: auto-approval.json으로 반복 작업 효율화
- **텔레메트리**: 팀의 Claude Code 사용 패턴 분석 가능

---

더 자세한 내용은 각 파일의 주석을 참고하세요.