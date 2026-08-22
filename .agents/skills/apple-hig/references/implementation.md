# 承認案の実装

このモードは、ユーザーが選択した画像、モック、スクリーンショット、Figma frameをUIへ反映する場合に使う。
文章のbriefしかない場合は、`ideation.md`で視覚的な仕様源を作る。

## 実装前の条件

1. 実装対象の画像を会話、添付、またはローカルファイルから一意に特定する。
2. 複数案から選ばれた場合は、ImageGen呼び出し順ではなく会話内の表示順で解決する。
3. 複数viewportの仕様源が必要な場合は、その一式が承認済みであることを確認する。
4. 対象リポジトリの技術スタック、デザインシステム、既存コンポーネント、テストコマンドを確認する。

視覚的な仕様源を特定できない場合は推測で実装しない。

## 実装

Web frontendでは、利用可能な場合にProduct Designの`image-to-code`を使い、そのdesign QAまで完了する。
native UIでは、対象リポジトリのplatformとframeworkに従って実装し、同じ画面と状態を操作できる手段でvisual QAを行う。
呼び出すskillは、その実行時に全文を読んで従う。

- 承認画像を視覚的な仕様源として扱い、プロダクト仕様を機能上の仕様源として扱う。
- 既存プロジェクトでは、既存のarchitecture、component、token、state managementへ統合する。
- 視覚的な都合だけで、product logic、data model、route、backendを変更しない。
- Webではsemantic HTMLを使い、native UIではplatformのaccessibility APIと標準componentを使う。
- keyboard操作、focus、accessible name、状態通知を対象platformの方法で実装する。
- text scaling、lightとdark、increased contrast、reduced motion、reduced transparencyを対象platformのsettingとAPIに応じて実装する。
- responsive layoutでは、画面幅ごとの優先順位と操作方法を保ち、画像を固定寸法で模写しない。
- animationは状態と空間関係を説明する範囲に限定する。

承認画像が明確なアクセシビリティ要件に反する場合は、その欠陥を黙って再現しない。
修正が画像の方向性を実質的に変える場合は、問題、HIG上の根拠、変更案を示してユーザーへ確認する。

## 検証

1. プロジェクト既定のformat、lint、typecheck、test、buildから、変更に関係する検査を実行する。
2. 承認画像と同じviewportと状態で実装画面をキャプチャする。
3. 参照画像と実装画面を直接比較する。
4. primary flow、keyboard操作、focus、text scaling、contrast、reduced settingsを対象範囲に応じて確認する。
5. design QAで見つかった高優先度の問題を修正し、再キャプチャする。

HTTP応答、build成功、server起動だけをvisual QAの代わりにしない。
確認できなかった状態は未確認として報告する。

## DoD

### 機能完了条件

- [ ] 承認された視覚的な仕様源を一意に特定している。
- [ ] 対象画面とprimary flowが仕様どおりに動作する。
- [ ] 既存のproduct logicと情報の意味を維持している。
- [ ] 対象viewportで情報の優先順位と主要操作を維持している。
- [ ] semantic element、keyboard操作、focus、accessible nameを実装している。

### テスト完了条件

- [ ] 変更に関係するformat、lint、typecheck、test、buildが成功している。
- [ ] 参照画像と同じviewportと状態で画面をキャプチャしている。
- [ ] 参照画像とのdesign QAを行い、高優先度の差異を解消している。
- [ ] text scaling、contrast、色以外の状態表現、reduced settingsを対象範囲に応じて確認している。
- [ ] 未確認事項を適合済みとして報告していない。

### 運用反映条件

- [ ] 変更ファイル、検証コマンド、visual QA結果、残課題を報告している。
- [ ] 参照したApple公式ページを報告している。
- [ ] ユーザーの指示なしにcommit、push、deployしていない。
