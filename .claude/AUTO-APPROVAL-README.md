# Claude Code Auto-Approval Configuration

## 📋 개요

이 설정 파일은 Claude Code가 사용자의 명시적 승인 없이 자동으로 실행할 수 있는 명령어들을 정의합니다.

## 🔑 주요 기능

### 자동 승인 카테고리

1. **읽기 전용 작업** (`read`)
   - 파일 내용 보기, 디렉토리 탐색
   - 위험도: 최소
   - 자동 승인: ✅

2. **코드 분석** (`analyze`)
   - 정적 분석, 타입 체크
   - 위험도: 최소
   - 자동 승인: ✅

3. **빌드 및 컴파일** (`build`)
   - 프로젝트 빌드, 개발 서버 실행
   - 위험도: 낮음
   - 자동 승인: ✅

4. **테스트 실행** (`test`)
   - 유닛 테스트, 통합 테스트
   - 위험도: 낮음
   - 자동 승인: ✅

5. **코드 포맷팅** (`format`)
   - Lint, Prettier, Black 등
   - 위험도: 낮음
   - 자동 승인: ✅

6. **Git 읽기** (`git-read`)
   - status, log, diff, branch 조회
   - 위험도: 최소
   - 자동 승인: ✅

7. **Git 쓰기** (`git-write`)
   - commit, push, merge
   - 위험도: 중간
   - 자동 승인: ❌ (수동 승인 필요)

## 🛡️ 보안 설정

### 명시적 거부 명령어
- `rm -rf /` - 루트 삭제
- Fork bomb - 시스템 마비
- `dd` 디스크 덮어쓰기
- `curl | sh` - 원격 스크립트 실행

### 제한된 경로
- `/etc`, `/sys`, `/proc` - 시스템 디렉토리
- `~/.ssh`, `~/.aws` - 인증 정보
- `.env` 파일들 - 환경 변수

### 민감한 환경 변수
- `*_KEY`, `*_SECRET`, `*_TOKEN` 패턴
- AWS, GitHub, OpenAI 관련 변수

## 🚀 자동 승인 명령어 예시

### NPM/Yarn
```bash
npm run dev        ✅ 자동 승인
npm test          ✅ 자동 승인
npm run build     ✅ 자동 승인
npm install       ❌ 수동 승인 필요
```

### Python
```bash
python script.py   ✅ 자동 승인
pytest            ✅ 자동 승인
black .           ✅ 자동 승인
pip install       ❌ 수동 승인 필요
```

### Git
```bash
git status        ✅ 자동 승인
git log          ✅ 자동 승인
git diff         ✅ 자동 승인
git commit       ❌ 수동 승인 필요
git push         ❌ 수동 승인 필요
```

### Docker
```bash
docker ps         ✅ 자동 승인
docker logs       ✅ 자동 승인
docker run        ❌ 수동 승인 필요
docker rm         ❌ 수동 승인 필요
```

### Java/Spring
```bash
./gradlew bootRun  ✅ 자동 승인
./gradlew test     ✅ 자동 승인
./gradlew build    ✅ 자동 승인
```

### Terraform
```bash
terraform plan     ✅ 자동 승인
terraform validate ✅ 자동 승인
terraform apply    ❌ 수동 승인 필요
terraform destroy  ❌ 수동 승인 필요
```

## ⚙️ 설정 커스터마이징

### 새로운 명령어 추가하기

```json
{
  "pattern": "^your-command\\s+",
  "category": "read",
  "description": "Your command description",
  "autoApprove": true
}
```

### 특정 명령어 차단하기

```json
{
  "pattern": "^dangerous-command",
  "description": "Why it's dangerous",
  "riskLevel": "critical"
}
```

## 📊 모니터링

- 자동 승인된 명령어는 로그에 기록됨
- 100개 명령어마다 요약 표시
- 연속 실패 5회 시 30초 쿨다운
- 최대 연속 명령어: 50개

## 🔄 업데이트

이 설정은 프로젝트와 팀의 필요에 따라 지속적으로 업데이트됩니다.

### 버전 히스토리
- v1.0.0 (2025-09-11): 초기 설정
  - 기본 읽기/쓰기 권한
  - 주요 개발 도구 지원
  - 보안 규칙 설정

## 💡 팁

1. **개발 환경**: 로컬 개발에서는 자동 승인을 활성화하여 생산성 향상
2. **프로덕션**: 프로덕션 환경에서는 더 엄격한 규칙 적용
3. **팀 설정**: 팀의 워크플로우에 맞게 커스터마이징

## ⚠️ 주의사항

- 이 설정은 로컬 개발 환경용입니다
- 프로덕션 서버에서는 더 제한적인 설정을 사용하세요
- 정기적으로 보안 규칙을 검토하고 업데이트하세요