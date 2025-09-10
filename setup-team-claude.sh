#!/bin/bash

# Team Claude Setup Script
# Sets up standardized Claude Code environment for team members

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude.backup.$(date +%Y%m%d_%H%M%S)"

echo "🚀 Setting up Team Claude Configuration..."
echo "Project: $PROJECT_DIR"
echo "Target: $CLAUDE_DIR"

# 1. Backup existing configuration
if [ -d "$CLAUDE_DIR" ]; then
    echo "📦 Backing up existing Claude config to: $BACKUP_DIR"
    mv "$CLAUDE_DIR" "$BACKUP_DIR"
fi

# 2. Create fresh Claude directory
mkdir -p "$CLAUDE_DIR"

# 3. Copy team configuration
echo "📋 Installing team configuration..."

# Copy SuperClaude framework
cp "$PROJECT_DIR/.claude/CLAUDE.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/COMMANDS.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/FLAGS.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/PRINCIPLES.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/RULES.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/MCP.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/PERSONAS.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/ORCHESTRATOR.MD" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/MODES.MD" "$CLAUDE_DIR/"

# Copy team agents and commands
cp -r "$PROJECT_DIR/.claude/agents" "$CLAUDE_DIR/"
cp -r "$PROJECT_DIR/.claude/commands" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/AGENTS-REGISTRY.md" "$CLAUDE_DIR/"

# Copy project templates and configurations
cp -r "$PROJECT_DIR/.claude/templates" "$CLAUDE_DIR/"
cp -r "$PROJECT_DIR/.claude/hooks" "$CLAUDE_DIR/"
cp -r "$PROJECT_DIR/.claude/scripts" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/INSTRUCTIONS.md" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/PROJECT.md" "$CLAUDE_DIR/"
cp "$PROJECT_DIR/.claude/CONVENTIONS.md" "$CLAUDE_DIR/"

# 4. Create personal workspace directories
echo "👤 Creating personal workspace..."
mkdir -p "$CLAUDE_DIR/personal"
mkdir -p "$CLAUDE_DIR/personal/projects"
mkdir -p "$CLAUDE_DIR/personal/todos"
mkdir -p "$CLAUDE_DIR/personal/shell-snapshots"

# 5. Set up team configuration file
cat > "$CLAUDE_DIR/team-config.json" << EOF
{
  "team": "Development Team",
  "version": "1.0.0",
  "setup_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "agents_count": $(ls "$CLAUDE_DIR/agents" | wc -l | tr -d ' '),
  "superclaude_enabled": true,
  "backup_location": "$BACKUP_DIR"
}
EOF

# 6. Set permissions
chmod -R 755 "$CLAUDE_DIR"

# 7. Verification
echo "✅ Verification:"
echo "   SuperClaude Framework: $(test -f "$CLAUDE_DIR/COMMANDS.MD" && echo 'Active' || echo 'Missing')"
echo "   Available Agents: $(ls "$CLAUDE_DIR/agents" | wc -l | tr -d ' ')"
echo "   Team Commands: $(ls "$CLAUDE_DIR/commands" | wc -l | tr -d ' ')"
echo "   Personal Workspace: $(test -d "$CLAUDE_DIR/personal" && echo 'Ready' || echo 'Missing')"
echo "   Core Framework Files: $(ls "$CLAUDE_DIR"/{CLAUDE,PERSONAS,ORCHESTRATOR,MODES}.MD 2>/dev/null | wc -l | tr -d ' ')/4"

echo ""
echo "🎉 Team Claude setup complete!"
echo ""
echo "📚 Usage:"
echo "   @agent:spring-boot-architect    - Use Java/Spring expert"
echo "   @agent:aws-terraform-architect  - Use AWS infrastructure expert"
echo "   @workflow-orchestrator          - Use workflow automation"
echo "   /build /analyze /implement      - Use SuperClaude commands"
echo ""
echo "🔧 Backup location: $BACKUP_DIR"
echo "📋 Team config: $CLAUDE_DIR/team-config.json"

# 8. Install SuperClaude Framework
echo "🚀 Installing SuperClaude Framework..."

# Check if SuperClaude is already installed
if command -v SuperClaude &> /dev/null; then
    echo "   SuperClaude already installed: $(SuperClaude --version 2>/dev/null || echo 'unknown version')"
else
    echo "   Installing SuperClaude using pipx..."
    if command -v pipx &> /dev/null; then
        pipx install SuperClaude && echo "   ✅ SuperClaude installed via pipx"
    elif command -v pip3 &> /dev/null; then
        pip3 install --user SuperClaude && echo "   ✅ SuperClaude installed via pip3"
    elif command -v pip &> /dev/null; then
        pip install --user SuperClaude && echo "   ✅ SuperClaude installed via pip"
    else
        echo "   ❌ No pip/pipx found. Please install Python and pip first."
        echo "   📋 Manual installation: pip install --user SuperClaude"
    fi
fi

 # Run SuperClaude installer with automated responses
if command -v SuperClaude &> /dev/null; then
    echo "   Configuring SuperClaude with full components..."
    
    # Automated installation: Skip MCP servers (7), Install all components (all), Confirm (y)
    echo -e "7\nall\ny" | SuperClaude install --force 2>/dev/null || {
        echo "   ⚠️ Interactive installation failed, trying alternative method..."
        SuperClaude install --quiet 2>/dev/null || echo "   ⚠️ SuperClaude configuration may need manual setup"
    }
    
    echo "   ✅ SuperClaude Framework configured"
    echo "   📊 Components: $(find "$CLAUDE_DIR" -name "MODE_*.md" | wc -l | tr -d ' ') behavioral modes installed"
else
    echo "   ❌ SuperClaude installation failed. Please install manually."
fi

# 9. Quick test
echo "🧪 Quick test..."
if command -v claude &> /dev/null; then
    echo "   Claude Code CLI: Available"
else
    echo "   Claude Code CLI: Not found (install from https://claude.ai/code)"
fi

if command -v SuperClaude &> /dev/null; then
    echo "   SuperClaude Framework: Available"
else
    echo "   SuperClaude Framework: Not found (see manual installation below)"
fi

echo ""
echo "✨ Ready to use team Claude environment!"
echo ""
echo "⚠️  IMPORTANT: SuperClaude 활성화를 위해 Claude Code를 재시작해주세요:"
echo "   1. 현재 Claude Code 세션 종료"
echo "   2. 새로운 Claude Code 세션 시작"
echo "   3. 다른 프로젝트에서 '/sc' 명령어로 테스트"