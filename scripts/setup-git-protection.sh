#!/bin/bash
# Git 브랜치 보호 설정 스크립트

set -e

echo "🔧 Git 브랜치 보호 설정을 시작합니다..."

# 1. Git hooks 디렉토리 생성
mkdir -p .git/hooks

# 2. Pre-commit hook 설정
cat > .git/hooks/pre-commit << 'HOOK_EOF'
#!/bin/bash
# 보호된 브랜치 직접 커밋 방지

BRANCH=$(git rev-parse --abbrev-ref HEAD)
PROTECTED_BRANCHES="^(main|develop|master)$"

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
HOOK_EOF

# 3. Pre-push hook 설정
cat > .git/hooks/pre-push << 'HOOK_EOF'
#!/bin/bash
# main/develop 브랜치로 직접 push 방지

while read local_ref local_oid remote_ref remote_oid
do
    if [[ "$remote_ref" =~ refs/heads/(main|develop|master) ]]; then
        echo "❌ '$remote_ref' 브랜치로 직접 push할 수 없습니다."
        echo "✅ Pull Request를 통해 코드를 병합하세요."
        exit 1
    fi
done
HOOK_EOF

# 4. 실행 권한 부여
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push

echo "✅ Git hooks 설정 완료!"
echo ""
echo "📋 테스트 방법:"
echo "1. 현재 브랜치 확인: git branch --show-current"
echo "2. main/develop 브랜치에서 커밋 시도 → 차단되어야 함"
echo "3. feature 브랜치 생성 후 커밋 → 허용되어야 함"
