#!/bin/bash
# Claude Code PR 준비 스크립트

set -e

CURRENT_BRANCH=$(git branch --show-current)

echo "🔍 Pull Request 준비 체크리스트"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 현재 브랜치: $CURRENT_BRANCH"
echo ""

# 1. Git 상태 확인
echo "1️⃣ Git 상태 확인:"
CHANGES=$(git status --porcelain)
if [ -z "$CHANGES" ]; then
    echo "   ✅ 모든 변경사항이 커밋되었습니다."
else
    echo "   ⚠️  커밋되지 않은 변경사항이 있습니다:"
    git status --short
fi
echo ""

# 2. 브랜치가 develop에서 분기되었는지 확인
echo "2️⃣ 브랜치 분기 기준점 확인:"
if git show-ref --verify --quiet refs/heads/develop; then
    MERGE_BASE=$(git merge-base $CURRENT_BRANCH develop 2>/dev/null || echo "")
    DEVELOP_HEAD=$(git rev-parse develop 2>/dev/null || echo "")
    
    if [[ -n "$MERGE_BASE" && -n "$DEVELOP_HEAD" && "$MERGE_BASE" != "$DEVELOP_HEAD" ]]; then
        echo "   ⚠️  브랜치가 최신 develop에서 분기되지 않았습니다."
        echo "   🔄 develop 브랜치 rebase를 권장합니다:"
        echo "      git rebase develop"
        echo ""
    else
        echo "   ✅ 최신 develop에서 분기되었습니다."
        echo ""
    fi
else
    echo "   ℹ️  develop 브랜치가 없습니다. main 브랜치 기준으로 확인하세요."
    echo ""
fi

# 3. 최근 커밋 메시지 확인
echo "3️⃣ 최근 커밋 메시지:"
git log --oneline -3
echo ""

# 4. 원격 브랜치 상태 확인
echo "4️⃣ 원격 브랜치 상태:"
REMOTE_BRANCH="origin/$CURRENT_BRANCH"
if git ls-remote --exit-code --heads origin $CURRENT_BRANCH >/dev/null 2>&1; then
    echo "   ✅ 원격 브랜치가 존재합니다: $REMOTE_BRANCH"
    AHEAD=$(git rev-list --count $REMOTE_BRANCH..$CURRENT_BRANCH 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count $CURRENT_BRANCH..$REMOTE_BRANCH 2>/dev/null || echo "0")
    
    if [ "$AHEAD" -gt 0 ]; then
        echo "   📤 푸시할 커밋: $AHEAD 개"
    fi
    if [ "$BEHIND" -gt 0 ]; then
        echo "   📥 원격에서 가져올 커밋: $BEHIND 개"
    fi
else
    echo "   📤 원격 브랜치가 없습니다. 첫 번째 푸시가 필요합니다."
fi
echo ""

# 5. PR 생성 가이드
echo "✅ Pull Request 생성 단계:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣ 브랜치를 원격 저장소에 푸시:"
echo "   git push origin $CURRENT_BRANCH"
echo ""
echo "2️⃣ GitHub에서 PR 생성:"
echo "   - Base: develop (또는 main)"
echo "   - Compare: $CURRENT_BRANCH"
echo ""
echo "3️⃣ PR 제목 예시:"
TICKET_ID=$(echo $CURRENT_BRANCH | grep -oE '[A-Z]+-[0-9]+' || echo "")
DESCRIPTION=$(echo $CURRENT_BRANCH | sed 's/^[^/]*\///g' | sed 's/-/ /g')
if [ -n "$TICKET_ID" ]; then
    echo "   [$TICKET_ID] $DESCRIPTION"
else
    echo "   $(echo $DESCRIPTION | sed 's/\b\w/\U&/g')"
fi
echo ""
echo "4️⃣ PR 설명에 포함할 내용:"
echo "   - 🎯 변경 사항 요약"
echo "   - ✅ 테스트 결과"
echo "   - 📝 리뷰 포인트"
echo "   - 🔗 관련 이슈/티켓 링크"
echo ""
