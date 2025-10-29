import { outdent, Snippet } from "./deps.ts";

const check_pr_review_text = outdent`
  PRの対応してないメッセージやレビューを確認して、それぞれの妥当性と対応するべき内容かどうかをそれぞれ検討してください。
  まだ実際の編集はせずに調査した内容を判断しやすいように整理して、このプロジェクトの ./tmp/ai ディレクトリ以下にmarkdown形式で保存して対応方針を決めるのを待ってください。
  修正方針やコードが提供されていれば、それも含めて整理してください。
`;
const _check_pr_review: Snippet = {
  name: "check_pr_review",
  text: check_pr_review_text,
  params: [],
  render: () => check_pr_review_text,
};

const _fix_pr_review_text = outdent`
  PRレビューの調査結果とそれに対して決めた修正方針に基づいて、コードやドキュメントの修正を行ってください。
  対応完了後は適宜commitを作成してください。
`;
const _fix_pr_review: Snippet = {
  name: "reply_to_pr_review",
  text: _fix_pr_review_text,
  params: [],
  render: () => _fix_pr_review_text,
};

const _reply_to_pr_review_text = outdent`
  修正内容をpushしてそれぞれのレビューやコメントに対応内容を返信してください。
`;
const _reply_to_pr_review: Snippet = {
  name: "reply_to_pr_review",
  text: _reply_to_pr_review_text,
  params: [],
  render: () => _reply_to_pr_review_text,
};

export default {
  _check_pr_review,
  _fix_pr_review,
  _reply_to_pr_review,
};
