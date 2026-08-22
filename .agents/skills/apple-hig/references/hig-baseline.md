# HIGの共通評価基準

この文書は、Apple公式HIGをWebアプリやクロスプラットフォームUIへ適用するための評価基準を定める。
Apple公式HIGの要約や複製ではない。
現在の公式記述と異なる場合は、実行時に取得した公式記述を優先する。

## 公式情報の確認

最初にHIGの入口とDesign principlesを確認し、作業対象に関係するfoundation、pattern、component、input、platformのページだけを追加で読む。

- HIG：https://developer.apple.com/design/human-interface-guidelines/
- Design principles：https://developer.apple.com/design/human-interface-guidelines/design-principles
- Accessibility：https://developer.apple.com/design/human-interface-guidelines/accessibility
- Layout：https://developer.apple.com/design/human-interface-guidelines/layout
- Typography：https://developer.apple.com/design/human-interface-guidelines/typography
- Color：https://developer.apple.com/design/human-interface-guidelines/color
- Materials：https://developer.apple.com/design/human-interface-guidelines/materials
- Motion：https://developer.apple.com/design/human-interface-guidelines/motion

ネイティブアプリでは、iOS、iPadOS、macOSなど対象プラットフォームのページも確認する。
Webアプリでは、各プラットフォームの見た目を直接コピーせず、人間の認知、操作、適応性に関する原則をWebの技術へ翻訳する。

## プラットフォームへの翻訳

- iOS、iPadOS、macOSなどのnative UIでは、対象OSのcomponent、input、accessibility API、windowingの規約を使う。
- Webでは、semantic HTML、CSS、Pointer Events、keyboard event、media queryへ翻訳する。
- Electronなどのdesktop UIでは、Web技術だけでなくwindow、menu、keyboard shortcut、focus復帰などOSとの統合も確認する。
- platform固有の規約値を別のplatformへそのまま移植しない。値を対応付ける場合は、操作密度と入力手段が近いことを説明する。

## プロダクトと操作

次の状態を満たしているか確認する。

- 画面の目的、現在地、主要タスク、次の操作が短時間で理解できる。
- コンテンツと操作領域を視覚的、意味的に区別できる。
- コントロールが作用対象の近くにあり、結果を予測できる。
- 入力中、処理中、完了、警告、エラーの状態が適切なタイミングで分かる。
- 取消、戻る、再試行など、失敗から回復する経路がある。
- 頻出操作を前面に置き、詳細や高度な操作を段階的に開示している。
- 同じ見た目の要素が同じ振る舞いを持ち、ナビゲーションとラベルが一貫している。
- Delightを装飾の追加として扱わず、主要タスクの完了感、応答性、細部の品質から生み出している。

## レイアウトと適応

- 画面幅、向き、ウインドウサイズ、文字サイズ、言語が変わっても文脈と主要機能を失わない。
- レスポンシブ対応を単純縮小として扱わず、画面幅ごとに情報の優先順位と操作方法を再構成する。
- 小さい文字へ逃げず、並び替え、折り畳み、詳細画面、領域内スクロールを使い分ける。
- 主要コンテンツより先に、装飾、ブランド、空のsurfaceが画面を占有しない。
- spacing、grouping、alignment、typographyで関係を示し、border、shadow、cardの追加を最初の手段にしない。
- ページ全体の不要な横スクロールを避ける。横長の情報が必要な場合は、文脈を保てる限定領域で扱う。

## アクセシビリティ

数値は対象プラットフォームの現行HIGがより厳しい場合に更新する。

- 本文と操作ラベルを200%まで拡大しても、主要タスクを完了できるレイアウトを目標にする。
- native UIでは対象platformの現行HIGにあるtarget sizeを使う。Webのtouch surfaceでは、iOSとiPadOSの44×44ptを44×44 CSS px相当の基準として扱い、隣接する対象との間隔も確保する。
- 通常サイズの文字は4.5:1、大きい文字または太字は3:1を最低コントラストの基準として扱う。
- 色だけで状態、選択、エラー、傾向、操作可能性を伝えない。ラベル、数値、形状、iconなどを併用する。
- keyboardだけで主要タスクを完了でき、focus順序とfocus表示が視覚的な構造に一致する。
- semantic element、accessible name、見出し構造、状態通知をコードまたは支援技術で確認する。
- Webでは`prefers-reduced-motion`に応じて大きな移動、parallax、bounceを抑え、意味を保つ代替表現へ切り替える。
- Webでは`prefers-reduced-transparency`と`prefers-contrast`に対して、可読性を保つsurfaceと境界を用意する。
- native UIではReduce Motion、Reduce Transparency、Increase Contrastなど、対象platformのaccessibility settingへ追従する。
- light、dark、increased contrastの各状態で、文字、icon、操作部品、focusが判別できる。

スクリーンショットだけでは、keyboard操作、screen reader、focus、text scaling、reduced settingsを検証できない。
コード調査または実機操作を行っていない項目は、未確認として報告する。

## タイポグラフィと色

- 文字サイズ、weight、line-height、trackingを役割ごとに設計し、サイズだけで階層を作らない。
- 長文、数値、表、操作ラベルの用途に合う書体を選び、装飾書体を本文へ広げない。
- system fontは有力な既定候補だが、プロダクトの要件とブランドに合わない場合まで強制しない。
- 色を意味と一貫して対応させ、同じ色を操作可能性と装飾へ混用しない。
- custom colorはlight、dark、increased contrastの組み合わせを確認する。
- translucencyとblurは階層や空間関係を説明する場合だけ使い、surfaceの入れ子や可読性低下を生まない。

## モーションとフィードバック

- pointer downまたはtouch downから反応し、操作中も連続的なフィードバックを返す。
- gestureで直接操作する要素は入力へ追従し、途中で掴み直し、反転、中断ができる。
- enterとexitの経路、triggerと表示先の位置関係を一貫させる。
- animation中に入力を一律で無効化しない。
- 動きは状態変化と空間関係を説明し、注意を奪う装飾として反復しない。

gesture、spring、momentum、rubber-banding、materialの具体的な実装判断が必要な場合は`apple-design`を併用する。

## 証拠の区別

報告では、次の証拠を混同しない。

- **画面で確認**：現在のスクリーンショットまたは実際の操作で確認した。
- **コードで確認**：実装と状態分岐を読んで確認した。
- **自動検査で確認**：test、lint、accessibility toolなどの結果で確認した。
- **公式情報**：実行時に取得したApple公式ページが根拠になっている。
- **未確認**：必要な環境、状態、支援技術がなく確認できていない。

一部の画面や静的な証拠から、プロダクト全体のHIG適合やアクセシビリティ適合を保証しない。
