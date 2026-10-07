# 新規メンバー向けローカル開発環境のセットアップ手順

リポジトリをクローンした後、まずはプロジェクトルートで以下のコマンドを実行してください。Docker Composeを利用して、ローカルテスト用のPostgreSQLとRedisが自動的に起動します。

```bash
docker compose up -d
cp .env.example .env
npm install
npm run dev
```

起動後にブラウザで `http://localhost:3000` を開き、ログイン画面が表示されることを確認してください。環境変数の設定で不明点があれば、いつでも開発チャンネルで質問してください。