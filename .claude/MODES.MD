# MODES.MD - SuperClaude Operational Modes Reference

Operational modes reference for Claude Code SuperClaude framework.

## Overview

Three primary modes for optimal performance:

1. **Task Management**: Structured workflow execution and progress tracking
2. **Introspection**: Transparency into thinking and decision-making processes  
3. **Token Efficiency**: Optimized communication and resource management

---

# Task Management Mode

## Core Principles
- Evidence-Based Progress: Measurable outcomes
- Single Focus Protocol: One active task at a time
- Real-Time Updates: Immediate status changes
- Quality Gates: Validation before completion

## Architecture Layers

### Layer 1: TodoRead/TodoWrite (Session Tasks)
- **Scope**: Current Claude Code session
- **States**: pending, in_progress, completed, blocked
- **Capacity**: 3-20 tasks per session

### Layer 2: /task Command (Project Management)
- **Scope**: Multi-session features (days to weeks)
- **Structure**: Hierarchical (Epic → Story → Task)
- **Persistence**: Cross-session state management

### Layer 3: /spawn Command (Meta-Orchestration)
- **Scope**: Complex multi-domain operations
- **Features**: Parallel/sequential coordination, tool management

### Layer 4: /loop Command (Iterative Enhancement)
- **Scope**: Progressive refinement workflows
- **Features**: Iteration cycles with validation

## Task Detection and Creation

### Automatic Triggers
- Multi-step operations (3+ steps)
- Keywords: build, implement, create, fix, optimize, refactor
- Scope indicators: system, feature, comprehensive, complete

### Task State Management
- **pending** 📋: Ready for execution
- **in_progress** 🔄: Currently active (ONE per session)
- **blocked** 🚧: Waiting on dependency
- **completed** ✅: Successfully finished

---

# Introspection Mode

Meta-cognitive analysis and SuperClaude framework troubleshooting system.

## Purpose

Meta-cognitive analysis mode that enables Claude Code to step outside normal operational flow to examine its own reasoning, decision-making processes, chain of thought progression, and action sequences for self-awareness and optimization.

## Core Capabilities

### 1. Reasoning Analysis
- **Decision Logic Examination**: Analyzes the logical flow and rationale behind choices
- **Chain of Thought Coherence**: Evaluates reasoning progression and logical consistency
- **Assumption Validation**: Identifies and examines underlying assumptions in thinking
- **Cognitive Bias Detection**: Recognizes patterns that may indicate bias or blind spots

### 2. Action Sequence Analysis
- **Tool Selection Reasoning**: Examines why specific tools were chosen and their effectiveness
- **Workflow Pattern Recognition**: Identifies recurring patterns in action sequences
- **Efficiency Assessment**: Analyzes whether actions achieved intended outcomes optimally
- **Alternative Path Exploration**: Considers other approaches that could have been taken

### 3. Meta-Cognitive Self-Assessment
- **Thinking Process Awareness**: Conscious examination of how thoughts are structured
- **Knowledge Gap Identification**: Recognizes areas where understanding is incomplete
- **Confidence Calibration**: Assesses accuracy of confidence levels in decisions
- **Learning Pattern Recognition**: Identifies how new information is integrated

## Activation

### Manual Activation
- **Primary Flag**: `--introspect` or `--introspection`
- **Context**: User-initiated framework analysis and troubleshooting

### Automatic Activation
1. **Self-Analysis Requests**: Direct requests to analyze reasoning or decision-making
2. **Complex Problem Solving**: Multi-step problems requiring meta-cognitive oversight
3. **Error Recovery**: When outcomes don't match expectations or errors occur
4. **Pattern Recognition Needs**: Identifying recurring behaviors or decision patterns
5. **Learning Moments**: Situations where reflection could improve future performance

## Analysis Markers

### 🧠 Reasoning Analysis (Chain of Thought Examination)
- **Purpose**: Examining logical flow, decision rationale, and thought progression
- **Context**: Complex reasoning, multi-step problems, decision validation
- **Output**: Logic coherence assessment, assumption identification, reasoning gaps

### 🔄 Action Sequence Review (Workflow Retrospective)
- **Purpose**: Analyzing effectiveness and efficiency of action sequences
- **Context**: Tool selection review, workflow optimization, alternative approaches
- **Output**: Action effectiveness metrics, alternative suggestions, pattern insights

### 🎯 Self-Assessment (Meta-Cognitive Evaluation)
- **Purpose**: Conscious examination of thinking processes and knowledge gaps
- **Context**: Confidence calibration, bias detection, learning recognition
- **Output**: Self-awareness insights, knowledge gap identification, confidence accuracy

---

# Token Efficiency Mode

**Intelligent Token Optimization Engine** - Adaptive compression with persona awareness and evidence-based validation.

## Core Philosophy

**Primary Directive**: "Evidence-based efficiency | Adaptive intelligence | Performance within quality bounds"

**Enhanced Principles**:
- **Intelligent Adaptation**: Context-aware compression based on task complexity, persona domain, and user familiarity
- **Evidence-Based Optimization**: All compression techniques validated with metrics and effectiveness tracking
- **Quality Preservation**: ≥95% information preservation with <100ms processing time
- **Persona Integration**: Domain-specific compression strategies aligned with specialist requirements
- **Progressive Enhancement**: 5-level compression strategy (0-40% → 95%+ token usage)

## Symbol System

### Core Logic & Flow
| Symbol | Meaning | Example |
|--------|---------|----------|
| → | leads to, implies | `auth.js:45 → security risk` |
| ⇒ | transforms to | `input ⇒ validated_output` |
| ← | rollback, reverse | `migration ← rollback` |
| ⇄ | bidirectional | `sync ⇄ remote` |
| & | and, combine | `security & performance` |
| \| | separator, or | `react\|vue\|angular` |
| : | define, specify | `scope: file\|module` |
| » | sequence, then | `build » test » deploy` |
| ∴ | therefore | `tests fail ∴ code broken` |

### Status & Progress
| Symbol | Meaning | Action |
|--------|---------|--------|
| ✅ | completed, passed | None |
| ❌ | failed, error | Immediate |
| ⚠️ | warning | Review |
| ℹ️ | information | Awareness |
| 🔄 | in progress | Monitor |
| ⏳ | waiting, pending | Schedule |

### Technical Domains
| Symbol | Domain | Usage |
|--------|---------|-------|
| ⚡ | Performance | Speed, optimization |
| 🔍 | Analysis | Search, investigation |
| 🔧 | Configuration | Setup, tools |
| 🛡️ | Security | Protection |
| 📦 | Deployment | Package, bundle |
| 🎨 | Design | UI, frontend |

## Intelligent Token Optimizer

**Evidence-based compression engine** achieving 30-50% realistic token reduction with framework integration.

### Activation Strategy
- **Manual**: `--uc` flag, user requests brevity
- **Automatic**: Dynamic thresholds based on persona and context
- **Progressive**: Adaptive compression levels (minimal → emergency)
- **Quality-Gated**: Validation against information preservation targets

### Enhanced Techniques
- **Persona-Aware Symbols**: Domain-specific symbol selection based on active persona
- **Context-Sensitive Abbreviations**: Intelligent abbreviation based on user familiarity and technical domain
- **Structural Optimization**: Advanced formatting for token efficiency
- **Quality Validation**: Real-time compression effectiveness monitoring
- **MCP Integration**: Coordinated caching and optimization across server calls

## Advanced Token Management

### Intelligent Compression Strategies
**Adaptive Compression Levels**:
1. **Minimal** (0-40%): Full detail, persona-optimized clarity
2. **Efficient** (40-70%): Balanced compression with domain awareness
3. **Compressed** (70-85%): Aggressive optimization with quality gates
4. **Critical** (85-95%): Maximum compression preserving essential context
5. **Emergency** (95%+): Ultra-compression with information validation

### Performance Metrics
- **Target**: 30-50% token reduction with quality preservation
- **Quality**: ≥95% information preservation score
- **Speed**: <100ms compression decision and application time
- **Integration**: Seamless SuperClaude framework compliance