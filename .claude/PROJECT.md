# Claude Global Config Project

## 프로젝트 개요
SuperClaude 프레임워크를 활용한 전역 Claude Code 설정 관리 시스템

## 주요 기능
- Java 21 헥사고날 아키텍처 컨벤션
- 자동화된 코드 검증 시스템
- Git 워크플로우 자동화
- StackKit Terraform 및 AWS Kit 전문 에이전트

## 디렉토리 구조
```
.claude/
├── CLAUDE.md              # 엔트리 포인트
├── JAVA_HEXAGONAL.md      # Java 아키텍처 규약
├── JAVA_VALIDATION.md     # 검증 및 Git 워크플로우
├── commands/              # 커스텀 명령어
│   └── husky-java.md     # Java CI/CD 자동화
└── agents/               # 전문 에이전트
    ├── stackkit-terraform-specialist.md
    └── aws-kit-specialist.md
```

## 사용 가능한 명령어
- `/husky-java` - Java 프로젝트 CI 검증
- `/husky-java --auto-fix` - 자동 수정 포함 검증
- `/husky-java --only-archunit` - 아키텍처만 검증

## 기술 스택
- Java 21
- Spring Boot 3.x
- Hexagonal Architecture
- ArchUnit
- Gradle/Maven