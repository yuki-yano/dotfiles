---
name: drawio
description: draw.io のネイティブ .drawio 図を生成し、必要に応じて PNG/SVG/PDF（XML埋め込み）へ書き出す。フローチャート、シーケンス図、ER図、構成図、draw.io形式の出力依頼で使う。
allowed-tools: Bash
---

# Draw.io 図作成スキル (Codex)

draw.io 図をネイティブな `.drawio` として生成する。必要に応じて draw.io Desktop CLI で `png` / `svg` / `pdf` / `jpg` に書き出す。

## ワークフロー

1. ユーザー依頼から出力形式を判断する（既定は `.drawio`、指定時は `png` / `svg` / `pdf` / `jpg`）
2. 要求された図の mxGraphModel XML を生成する
3. Bash のリダイレクトで `<name>.drawio` を保存する
4. 書き出し指定がある場合は draw.io CLI で変換する
5. 書き出し成功後、ユーザーが保持を求めない限り中間 `.drawio` を削除する
6. 生成したファイルパスを報告する

形式指定がない場合は `.drawio` のみを生成する。

## 出力形式

- 既定: `name.drawio`
- `png`: `name.drawio.png`（XML埋め込み）
- `svg`: `name.drawio.svg`（XML埋め込み）
- `pdf`: `name.drawio.pdf`（XML埋め込み）
- `jpg`: `name.drawio.jpg`（XML埋め込み非対応）

## Bash で保存

heredoc で XML を直接保存する。

```bash
cat > "$DRAWIO_FILE" <<'XML'
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
  </root>
</mxGraphModel>
XML
```

## draw.io CLI の検出

次の順で CLI を解決する。

1. `drawio` on `PATH`
2. macOS フォールバック: `/Applications/draw.io.app/Contents/MacOS/draw.io`
3. Windows フォールバック: `C:\Program Files\draw.io\draw.io.exe`

例:

```bash
if command -v drawio >/dev/null 2>&1; then
  DRAWIO_BIN="drawio"
elif [ -x "/Applications/draw.io.app/Contents/MacOS/draw.io" ]; then
  DRAWIO_BIN="/Applications/draw.io.app/Contents/MacOS/draw.io"
elif [ -x "/c/Program Files/draw.io/draw.io.exe" ]; then
  DRAWIO_BIN="/c/Program Files/draw.io/draw.io.exe"
else
  echo "draw.io CLI not found" >&2
  exit 1
fi
```

## 書き出しコマンド

`png` / `svg` / `pdf`:

```bash
"$DRAWIO_BIN" -x -f "$FORMAT" -e -b 10 -o "$OUTPUT" "$INPUT"
```

`jpg`:

```bash
"$DRAWIO_BIN" -x -f jpg -b 10 -o "$OUTPUT" "$INPUT"
```

書き出し成功後、かつユーザーが元ファイル保持を求めていない場合:

```bash
rm -f "$INPUT"
```

## ファイル命名

- 内容が分かる kebab-case を使う（`login-flow`, `database-schema`）
- 書き出し時は二重拡張子（`name.drawio.png` など）を優先し、埋め込みXML入りであることを明示する

## XML 要件

`.drawio` は mxGraphModel XML。ネイティブ `.drawio` 出力では XML を直接生成し、Mermaid/CSV 変換には依存しない。

最小構造:

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- diagram cells use parent="1" -->
  </root>
</mxGraphModel>
```

ルール:

- `id="0"` は root
- `id="1"` は既定レイヤーの親
- 各 `mxCell` の `id` は一意にする
- 属性値の特殊文字は `&amp;`, `&lt;`, `&gt;`, `&quot;` へエスケープする
- XMLコメント内で `--` は使わない

代表的なセル:

```xml
<mxCell id="2" value="Start" style="rounded=1;whiteSpace=wrap;" vertex="1" parent="1">
  <mxGeometry x="80" y="80" width="120" height="60" as="geometry"/>
</mxCell>
<mxCell id="3" value="Decision?" style="rhombus;whiteSpace=wrap;" vertex="1" parent="1">
  <mxGeometry x="80" y="190" width="120" height="80" as="geometry"/>
</mxCell>
<mxCell id="4" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="2" target="3" parent="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

## 出力ファイルを開く（ユーザーが求めた場合のみ）

- macOS: `open <file>`
- Linux: `xdg-open <file>`
- Windows: `cmd.exe /c start "" "<file>"`
