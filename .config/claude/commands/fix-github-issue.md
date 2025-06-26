---
description: Review specified GitHub issue, create branch, implement fix, and create pull request
---

# GitHub Issueの修正: #$ARGUMENTS

## 目標

指定されたGitHub Issueを確認し、問題を修正してプルリクエストを作成する

## 手順（厳密に従うこと）

ステップ 1. **Issueの状態確認**
- `mcp__github__get_issue` でIssueが"OPEN"であることを確認（GitHub MCP優先）
- 代替: `gh issue view $ARGUMENTS --json state -q .state` 
- 開いていない場合は作業を中止

ステップ 2. **Issueの詳細確認**
- `mcp__github__get_issue` でIssueの内容を読み込む（GitHub MCP優先）
- 代替: `gh issue view $ARGUMENTS`
- 問題の本質と要求事項を理解

ステップ 3. **ブランチの作成（重要）**
- Issueの内容から適切なブランチ名を生成:
- または手動で意味のある名前を指定: `git checkout -b fix/descriptive-branch-name`
- これにより main ブランチへの誤ったコミットを防ぐ

ステップ 4. **実装**
- コードベース内の関連箇所を特定（複数のサブエージェントで検索）
- 根本原因に対処する解決策を実装
- 必要に応じてテストを追加

ステップ 5. **コミットとPR作成**
- 適切なコミットメッセージで変更をコミット（Issue番号を含める）:
  ```bash
  git commit -m "Fix: <説明> (#$ARGUMENTS)"
  ```
- 現在のブランチをプッシュ: `git push -u origin HEAD`
- `mcp__github__create_pull_request` でPRを作成（GitHub MCP優先）
  - タイトルにIssue番号を含める
  - 本文で `Fixes #$ARGUMENTS` を記載して自動リンク
- 代替: `gh pr create --title "Fix: <説明> (#$ARGUMENTS)" --body "Fixes #$ARGUMENTS"`

ステップ 6. **修正記録の作成**
- `ai/log/fixes/YYYY-MM-DD-issue-$ARGUMENTS.md` に修正内容を記録
- 根本原因と解決方法を文書化

