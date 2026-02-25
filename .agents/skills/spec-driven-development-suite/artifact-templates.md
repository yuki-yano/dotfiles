# 成果物テンプレート

## 1. `spec.json` 初期テンプレート

```json
{
  "feature_name": "example-feature",
  "created_at": "2026-01-01T00:00:00Z",
  "updated_at": "2026-01-01T00:00:00Z",
  "language": "ja",
  "phase": "initialized",
  "approvals": {
    "requirements": {
      "generated": false,
      "approved": false
    },
    "design": {
      "generated": false,
      "approved": false
    },
    "tasks": {
      "generated": false,
      "approved": false
    }
  },
  "ready_for_implementation": false,
  "approval_log": []
}
```

## 2. `requirements.md` テンプレート

```markdown
# Requirements Document

## Introduction
[機能概要と価値]

## Requirements

### Requirement 1: [主要目的]
**Objective:** As a [role], I want [capability], so that [benefit]

#### Acceptance Criteria
1. WHEN [event]
   THEN [system] SHALL [response]
2. IF [precondition]
   THEN [system] SHALL [response]
```

## 3. `research.md` テンプレート

```markdown
# Research & Design Decisions

## Summary
- Feature: <feature-name>
- Discovery Scope: New Feature / Extension / Simple Addition / Complex Integration
- Key Findings:
  - Finding 1
  - Finding 2

## Research Log

### [Topic]
- Context:
- Sources Consulted:
- Findings:
- Implications:

## Architecture Pattern Evaluation
| Option | Description | Strengths | Risks | Notes |
| --- | --- | --- | --- | --- |
| Option A | ... | ... | ... | ... |

## Design Decisions
### Decision: <title>
- Context:
- Alternatives:
  1. ...
  2. ...
- Selected Approach:
- Rationale:
- Trade-offs:
- Follow-up:

## Risks & Mitigations
- Risk 1 — Mitigation
```

## 4. `design.md` テンプレート

```markdown
# Design Document

## Overview
[設計の目的と範囲]

## Architecture
[主要構成要素と責務]

## Components and Interfaces
[インターフェース、入出力、エラーハンドリング]

## Data Models
[永続化・DTO・制約]

## Testing Strategy
[単体・統合・E2E方針]
```

## 5. `tasks.md` テンプレート

```markdown
# Implementation Plan

- [ ] 1. [主要タスク]
- [ ] 1.1 [サブタスク]
  - [実施内容]
  - _Requirements: 1.1_

- [ ] 2. [次の主要タスク]
- [ ] 2.1 [サブタスク]
  - [実施内容]
  - _Requirements: 2.1_
```

## 6. 承認状態更新ルール（`spec.json`）

1. 自然言語承認で `approvals.<phase>.approved=true` を設定する。
2. `tasks.approved=true` の時点で `ready_for_implementation=true` にする。
3. 要件承認を取り消したら、
   - `approvals.requirements.approved=false`
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
4. 設計承認を取り消したら、
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
5. タスク承認を取り消したら、
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
6. `requirements.md` を更新したら、
   - `approvals.requirements.approved=false`
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
7. `design.md` を更新したら、
   - `approvals.design.approved=false`
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
8. `tasks.md` を更新したら、
   - `approvals.tasks.approved=false`
   - `ready_for_implementation=false`
9. すべての更新で `updated_at` を更新する。

## 7. 承認証跡ログテンプレート（`spec.json`）

```json
{
  "approval_log": [
    {
      "phase": "requirements",
      "action": "approve",
      "at": "2026-01-01T01:00:00Z",
      "message_summary": "要件を承認します"
    },
    {
      "phase": "tasks",
      "action": "revoke",
      "at": "2026-01-01T02:00:00Z",
      "message_summary": "タスク承認を取り消します"
    }
  ]
}
```
