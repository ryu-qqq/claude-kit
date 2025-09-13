#!/bin/bash
# Claude Code 안전한 작업 시작 스크립트

set -e

echo "🤖 Claude Code 작업 시작 검증..."
echo ""

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo "📋 현재 브랜치: $CURRENT_BRANCH"

# 보호된 브랜치에서 작업 중단
if [[ "$CURRENT_BRANCH" =~ ^(main|develop|master)$ ]]; then
    echo ""
    echo "🚨 CLAUDE CODE 작업 중단 🚨"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "❌ 현재 '$CURRENT_BRANCH' 브랜치는 보호된 브랜치입니다."
    echo "❌ 이 브랜치에서는 직접 수정할 수 없습니다."
    echo ""
    echo "✅ 안전한 작업을 위해 다음 중 하나를 선택하세요:"
    echo ""
    echo "1️⃣ 새 Feature 브랜치 생성:"
    echo "   git checkout -b feature/TICKET-123-your-description"
    echo ""
    echo "2️⃣ 기존 Feature 브랜치로 이동:"
    echo "   git branch -a  # 브랜치 목록 확인"
    echo "   git checkout feature/existing-branch"
    echo ""
    echo "3️⃣ 개발 브랜치에서 새 Feature 브랜치 생성:"
    echo "   git checkout develop"
    echo "   git pull origin develop"
    echo "   git checkout -b feature/new-feature-name"
    echo ""
    echo "💡 브랜치 네이밍 규칙:"
    echo "   feature/TICKET-ID-description"
    echo "   bugfix/TICKET-ID-description"
    echo "   hotfix/CRITICAL-ID-description"
    echo ""
    exit 1
fi

# Feature 브랜치에서 작업 가능
echo ""
echo "✅ Feature 브랜치에서 안전하게 작업 가능합니다!"
echo ""
echo "📋 작업 전 체크리스트:"
echo "  ☐ 최신 develop 브랜치 반영 확인"
echo "  ☐ 브랜치명이 네이밍 규칙에 맞는지 확인"
echo "  ☐ 작업 범위가 단일 기능/수정사항인지 확인"
echo ""
echo "🎯 이제 Claude Code에게 작업을 요청하세요!"
echo "   예: '로그인 기능을 구현해줘'"
echo "       'API 에러 핸들링을 개선해줘'"
