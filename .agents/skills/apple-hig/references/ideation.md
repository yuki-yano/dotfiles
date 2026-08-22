# ImageGenによる方向性探索

このモードは、実装前に視覚的な仕様源を作る場合に使う。
既存の視覚的な仕様源を忠実に実装する場合は、`implementation.md`へ進む。

## 使用するskill

利用可能な場合は、Product Designのrouterから`user-context`、`get-context`、`ideate`を順に使う。
視覚的な方向性の検討には`frontend-design`を使う。
motion、gesture、materialが方向性を左右する場合だけ`apple-design`を使う。
画像生成時は`imagegen`を使い、built-in ImageGenを選ぶ。

呼び出すskillは、その実行時に全文を読んで従う。
必要なskillまたはbuilt-in ImageGenが利用できない場合は、CLIや別の生成手段へ切り替えず、不足をユーザーへ報告する。

## 方向性を生成する前の確認

1. 対象ユーザー、主要タスク、対象画面、対象プラットフォームを、仕様源から特定する。
2. 既存プロジェクトでは、デザイントークン、主要コンポーネント、類似フロー、Storybook、既存スクリーンショットを必要な範囲で確認する。
3. 参考画像を実際に表示し、ImageGenへ添付できる状態か確認する。
4. 現在のApple公式HIGから、対象に関係するprinciple、foundation、pattern、component、inputを確認する。
5. briefが明確なら同じ内容を質問し直さず、短いbrief playbackの後に生成へ進む。

ImageGen promptには、プロダクト固有の情報とともに次を含める。

- 主要タスクとprimary action
- 対象viewportと入力手段
- 明確な視覚的階層と、コンテンツと操作領域の関係
- 画面幅や文字拡大へ適応する構造
- 色以外でも状態を伝える方法
- focus、touch target、contrast、reduced settingsへの配慮
- Apple純正アプリの複製やLiquid Glassの表面的な模倣を避ける指示

## 生成と選択

案の数、独立生成、表示順の解決、再生成、選択待ちにはProduct Designの`ideate`をそのまま適用する。
ユーザーが数を指定しない場合は、情報階層、layout、interaction model、product framingのいずれかが異なる3案を生成する。
配色だけが違う案は独立案として扱わない。

すべての案が会話内に表示されたら、表示順に基づいてユーザーの選択を待つ。
選択前にscaffold、依存関係導入、ファイル作成、コード実装、server起動へ進まない。

## レスポンシブ展開

複数の画面幅が対象の場合は、ユーザーがprimary viewportの案を選んだ後に、選択画像を実際に添付して残りのviewportを別々に生成する。
複数端末を一枚の画像へまとめない。

各viewportでcolor token、typography、signature element、情報の意味、主要操作を維持する。
layoutは単純縮小せず、入力手段と利用状況に合わせて再構成する。

ユーザーが選択と同時に修正を求めた場合は、primary viewportを先に修正する。
修正版が確定してから他のviewportへ展開する。
必要な一式が表示されたら、実装へ進まず、レスポンシブ一式の承認を待つ。

承認済み画像をリポジトリへ保存するのは、ユーザーが求めた場合または既存の運用で保存先が決まっている場合に限る。
既存ファイルを上書きしない。

## DoD

### 機能完了条件

- [ ] 仕様源と参考画像を必要な範囲で確認している。
- [ ] 現在のApple公式HIGを対象範囲に合わせて確認している。
- [ ] 指定数の独立したImageGen出力が会話内に表示されている。
- [ ] 各案が情報階層、layout、interaction model、product framingのいずれかで異なる。
- [ ] ユーザーが案を選択する前に実装していない。
- [ ] 必要な場合は、承認された方向性からviewport別の画像を生成している。

### テスト完了条件

- [ ] 生成画像を実際に表示して目視確認している。
- [ ] 主要情報、文字、操作部品に切れ、重なり、潰れがない。
- [ ] 主要タスクと次の操作を各viewportで識別できる。
- [ ] 状態の意味を色だけに依存していない。
- [ ] 小さいviewportがprimary viewportの単純縮小になっていない。
- [ ] 不足した生成結果がある場合は不足分だけを再生成している。

### 運用反映条件

- [ ] 参照したApple公式ページと、最終的なImageGen promptを報告している。
- [ ] 保存を求められた場合は、承認済み画像だけを非破壊的な名前で保存している。
- [ ] 未承認の画像を実装上の仕様源として扱っていない。
- [ ] ユーザーの指示なしにcommit、push、deployしていない。
