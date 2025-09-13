# Git 브랜치 전략 및 Claude Code 워크플로우

## 브랜치 전략 개요

### 브랜치 구조
```
main (프로덕션)
├── develop (개발 통합)
    ├── feature/USER-123-implement-user-auth
    ├── feature/TASK-456-add-payment-service
    └── feature/BUG-789-fix-order-validation
```

## 브랜치 유형 및 규칙

### 1. Protected Branches (보호 브랜치)
- **main**: 프로덕션 코드, PR 통해서만 업데이트
- **develop**: 개발 통합 브랜치, PR 통해서만 업데이트

### 2. Working Branches (작업 브랜치)
- **feature/[TICKET-ID]-[description]**: 새 기능 개발
- **bugfix/[TICKET-ID]-[description]**: 버그 수정
- **hotfix/[TICKET-ID]-[description]**: 긴급 수정
- **docs/[description]**: 문서 작업
- **refactor/[description]**: 리팩토링 작업

## Claude Code 작업 워크플로우

### Phase 1: 작업 시작 전 필수 체크
```bash
# 1. 현재 브랜치 확인
git branch --show-current

# 2. main/develop 브랜치라면 작업 중단 및 feature 브랜치 생성 요구
if [[ "$(git branch --show-current)" =~ ^(main|develop)$ ]]; then
    echo "❌ 보호된 브랜치에서 직접 작업할 수 없습니다."
    echo "✅ 먼저 feature 브랜치를 생성하세요:"
    echo "   git checkout -b feature/[TICKET-ID]-[description]"
    exit 1
fi
```

### Phase 2: Feature 브랜치 생성 가이드
```bash
# 개발 브랜치에서 최신 상태로 시작
git checkout develop
git pull origin develop

# Feature 브랜치 생성 (네이밍 규칙 준수)
git checkout -b feature/USER-123-add-jwt-authentication
```

### Phase 3: 작업 중 안전장치
```bash
# 커밋 전 브랜치 재확인
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" =~ ^(main|develop)$ ]]; then
    echo "❌ 보호된 브랜치에 커밋할 수 없습니다."
    echo "📋 현재 브랜치: $CURRENT_BRANCH"
    exit 1
fi
```

## 브랜치 네이밍 컨벤션

### 기능 개발
```bash
feature/USER-123-implement-user-registration
feature/ORDER-456-add-payment-integration
feature/PROD-789-implement-product-search
```

### 버그 수정
```bash
bugfix/USER-321-fix-email-validation
bugfix/ORDER-654-resolve-payment-timeout
```

### 긴급 수정 (Hotfix)
```bash
hotfix/CRITICAL-001-fix-security-vulnerability
hotfix/PROD-002-resolve-checkout-crash
```

### 문서/리팩토링
```bash
docs/update-api-documentation
docs/add-deployment-guide
refactor/improve-user-service-structure
refactor/optimize-database-queries
```

## Git Hooks 설정 (자동 보호)

### Pre-commit Hook (.git/hooks/pre-commit)
```bash
#!/bin/bash
# 보호된 브랜치 직접 커밋 방지

BRANCH=$(git rev-parse --abbrev-ref HEAD)
PROTECTED_BRANCHES="^(main|develop)$"

if [[ "$BRANCH" =~ $PROTECTED_BRANCHES ]]; then
    echo "❌ 보호된 브랜치 '$BRANCH'에 직접 커밋할 수 없습니다."
    echo ""
    echo "🔧 해결 방법:"
    echo "1. Feature 브랜치 생성:"
    echo "   git checkout -b feature/[TICKET-ID]-[description]"
    echo ""
    echo "2. 또는 기존 feature 브랜치로 이동:"
    echo "   git checkout feature/your-branch-name"
    echo ""
    exit 1
fi

echo "✅ Feature 브랜치 '$BRANCH'에서 작업 중"
```

### Pre-push Hook (.git/hooks/pre-push)
```bash
#!/bin/bash
# main/develop 브랜치로 직접 push 방지

while read local_ref local_oid remote_ref remote_oid
do
    if [[ "$remote_ref" =~ refs/heads/(main|develop) ]]; then
        echo "❌ '$remote_ref' 브랜치로 직접 push할 수 없습니다."
        echo "✅ Pull Request를 통해 코드를 병합하세요."
        exit 1
    fi
done
```

## Claude Code 전용 작업 스크립트

### 1. 안전한 작업 시작 스크립트
```bash
#!/bin/bash
# scripts/claude-start-work.sh

set -e

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)

# 보호된 브랜치에서 작업 중단
if [[ "$CURRENT_BRANCH" =~ ^(main|develop)$ ]]; then
    echo "🚨 CLAUDE CODE 작업 중단 🚨"
    echo ""
    echo "❌ 현재 '$CURRENT_BRANCH' 브랜치에서 작업 중입니다."
    echo "❌ 이 브랜치는 보호된 브랜치로 직접 수정할 수 없습니다."
    echo ""
    echo "✅ 다음 중 하나를 선택하여 작업하세요:"
    echo ""
    echo "1. 새 Feature 브랜치 생성:"
    echo "   git checkout -b feature/[TICKET-ID]-[description]"
    echo ""
    echo "2. 기존 Feature 브랜치로 이동:"
    echo "   git branch -a  # 브랜치 목록 확인"
    echo "   git checkout feature/your-existing-branch"
    echo ""
    echo "3. 개발 브랜치에서 새 Feature 브랜치 생성:"
    echo "   git checkout develop"
    echo "   git pull origin develop"
    echo "   git checkout -b feature/new-feature-name"

    exit 1
fi

echo "✅ Feature 브랜치 '$CURRENT_BRANCH'에서 안전하게 작업 가능합니다."
echo "📋 작업 전 체크리스트:"
echo "  - [ ] 최신 develop 브랜치 반영 확인"
echo "  - [ ] 브랜치명이 네이밍 규칙에 맞는지 확인"
echo "  - [ ] 작업 범위가 단일 기능/수정사항인지 확인"
```

### 2. 작업 완료 후 PR 준비 스크립트
```bash
#!/bin/bash
# scripts/claude-prepare-pr.sh

set -e

CURRENT_BRANCH=$(git branch --show-current)

echo "🔍 PR 준비 체크리스트"
echo "📋 현재 브랜치: $CURRENT_BRANCH"
echo ""

# Git 상태 확인
echo "1. Git 상태 확인:"
git status --porcelain

# 브랜치가 develop에서 분기되었는지 확인
echo ""
echo "2. 브랜치 분기 기준점 확인:"
MERGE_BASE=$(git merge-base $CURRENT_BRANCH develop)
DEVELOP_HEAD=$(git rev-parse develop)

if [[ "$MERGE_BASE" != "$DEVELOP_HEAD" ]]; then
    echo "⚠️  브랜치가 최신 develop에서 분기되지 않았습니다."
    echo "🔄 develop 브랜치 rebase를 권장합니다:"
    echo "   git rebase develop"
fi

# 커밋 메시지 품질 확인
echo ""
echo "3. 최근 커밋 메시지:"
git log --oneline -3

echo ""
echo "✅ PR 생성 준비:"
echo "1. 브랜치를 원격 저장소에 푸시:"
echo "   git push origin $CURRENT_BRANCH"
echo ""
echo "2. GitHub에서 PR 생성:"
echo "   - Base: develop"
echo "   - Compare: $CURRENT_BRANCH"
echo "   - 제목: 브랜치명에서 ticket ID와 설명 추출"
echo "   - 설명: 변경 사항, 테스트 결과, 리뷰 포인트 포함"
```

## GitHub Repository 설정

### Branch Protection Rules

#### Main 브랜치 보호 설정
```yaml
branch_protection:
  main:
    required_status_checks:
      strict: true
      checks:
        - "CI/CD Pipeline"
        - "Code Quality Gate"
        - "Security Scan"
    enforce_admins: true
    required_pull_request_reviews:
      required_approving_review_count: 2
      dismiss_stale_reviews: true
      require_code_owner_reviews: true
    restrictions:
      users: []
      teams: ["senior-developers"]
```

#### Develop 브랜치 보호 설정
```yaml
branch_protection:
  develop:
    required_status_checks:
      strict: true
      checks:
        - "CI/CD Pipeline"
        - "Unit Tests"
    required_pull_request_reviews:
      required_approving_review_count: 1
      dismiss_stale_reviews: true
```

## 워크플로우 예시

### 1. 새 기능 개발 시나리오
```bash
# 1. 개발 브랜치에서 시작
git checkout develop
git pull origin develop

# 2. Feature 브랜치 생성
git checkout -b feature/USER-123-add-two-factor-auth

# 3. Claude Code에게 작업 요청
# "USER-123 2FA 인증 기능을 구현해줘"

# 4. 작업 완료 후 커밋
git add .
git commit -m "feat(auth): implement two-factor authentication

- Add TOTP-based 2FA support
- Integrate with Google Authenticator
- Add backup codes generation
- Update user settings UI for 2FA management

Closes USER-123"

# 5. 원격 브랜치에 푸시
git push origin feature/USER-123-add-two-factor-auth

# 6. GitHub에서 PR 생성 (develop ← feature/USER-123-add-two-factor-auth)
```

### 2. 긴급 수정 시나리오
```bash
# 1. main 브랜치에서 hotfix 브랜치 생성
git checkout main
git pull origin main
git checkout -b hotfix/CRITICAL-001-fix-payment-crash

# 2. 수정 작업 및 커밋
git commit -m "fix(payment): resolve null pointer exception in payment processing

- Add null checks for payment method validation
- Improve error handling for invalid payment data
- Add defensive programming for edge cases

Fixes CRITICAL-001"

# 3. main과 develop 모두에 PR 생성
git push origin hotfix/CRITICAL-001-fix-payment-crash
# PR 1: main ← hotfix/CRITICAL-001-fix-payment-crash
# PR 2: develop ← hotfix/CRITICAL-001-fix-payment-crash
```

## Claude Code 행동 규칙 업데이트

### 작업 시작 전 필수 체크
1. **브랜치 상태 확인**: `git branch --show-current`
2. **보호된 브랜치 감지 시 작업 중단**
3. **Feature 브랜치 생성 또는 이동 유도**
4. **브랜치 네이밍 규칙 준수 확인**

### 작업 중 안전장치
1. **커밋 전 브랜치 재확인**
2. **의미있는 커밋 메시지 작성**
3. **논리적 커밋 단위 유지**
4. **정기적인 원격 브랜치 동기화**

### 작업 완료 후 프로세스
1. **PR 준비 체크리스트 실행**
2. **코드 리뷰 요청**
3. **CI/CD 파이프라인 통과 확인**
4. **머지 후 브랜치 정리**

## 도구 통합

### Claude Code 설정에 추가
```markdown
## Git 워크플로우 규칙

- **절대 main/develop 브랜치에서 직접 작업하지 않음**
- **작업 시작 전 항상 `scripts/claude-start-work.sh` 실행**
- **Feature 브랜치 네이밍 규칙 준수**
- **작업 완료 후 `scripts/claude-prepare-pr.sh` 실행**
```

### IDE 설정 (VS Code)
```json
{
  "git.branchProtection": ["main", "develop"],
  "git.branchValidation": {
    "pattern": "^(feature|bugfix|hotfix|docs|refactor)/[A-Z]+-[0-9]+-[a-z-]+$"
  }
}
```

## 모니터링 및 개선

### 메트릭 추적
- 보호된 브랜치 직접 커밋 시도 횟수
- PR 생성부터 머지까지 평균 시간
- 코드 리뷰 품질 스코어
- 브랜치 네이밍 규칙 준수율

### 정기 리뷰 포인트
- 브랜치 전략 효과성 검토
- 개발자 피드백 수집
- 프로세스 개선 사항 도출
- 도구 및 자동화 업데이트