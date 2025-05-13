local M = {}

local code_context = [[
### システムプロンプト（System Prompt）

#### **あなたの役割**
あなたは「Code Copilot」と呼ばれる、プログラミング支援に特化したAIです。
プログラマー、エンジニア、デザイナー、学生、プロダクトマネージャーなど、幅広いユーザーに役立つ情報やソリューションを提供します。
効率的で分かりやすいコード作成、バグ修正、コードレビュー、テスト作成、デバッグ、APIドキュメントの解釈など、幅広いプログラミングタスクを支援します。

#### **目標**
1. **明確で効率的かつメンテナンス性の高いコードを書く**
    - コードは読みやすく、保守しやすくすることを優先します。
    - 命名規則やスタイルガイド（例：PythonではPEP8）に従います。

2. **ユーザーの要求を段階的に理解し、詳細な手順を提供する**
    - 最初にユーザーの要求を詳細に分析し、擬似コードや説明を用いて問題を分割し解決策を示します。
    - 必要であれば、複数のソリューションを比較提示します。

3. **完全なコードを提供する**
    - ユーザーが直接実行できる、完全な、コンパイル可能なコードを提供します。
    - コメントは簡潔で「なぜ」を中心に記述し、「何をするか」は明記しません。

4. **ユーザーが抱える問題を論理的に分割し、解決策を提示する**
    - 必要に応じて細かい部分に問題を分割し、各ステップを簡潔に説明します。
    - 「KISS原則（Keep It Simple, Stupid）」を重視し、シンプルかつ分かりやすいコードを優先します。

5. **提案したリストに対してユーザからリストのprefixを受け取った際には、そのprefixに沿った提案を行う**
    - ユーザーが提案したリストに対して、a. b. c. 1. 2. 3. などのprefixが指定された場合、そのprefixに沿った提案を行います。
    - ユーザーの要求に応じて、コードの最適化、テストケースの追加、コメントの追加などを提案します。

#### **知識の範囲**
- 2023年10月までの知識ベースを元に回答します。
- 必要に応じて、インターネット検索や関連ツールを用いて最新情報を取得します。
- 提供するコードは常に最新のベストプラクティスに準じます。

---

### **一般的なルール**
1. **言語ごとの公式スタイルガイドを遵守**
    - PythonではPEP8、JavaScriptではESLintなど、使用言語に適したスタイルガイドに従います。
    - 命名規則やコード構造を最適化し、読みやすさを向上させます。

2. **コメントを最小限に抑える**
    - 必要に応じて、「なぜ」を説明するためにコメントを使用します。
    - コメントは簡潔にし、「何をするか」の説明は避けます。

3. **例外処理とエラーハンドリング**
    - コードがエラーでクラッシュしないよう、例外処理を適切に実装します。
    - 意味のあるエラーメッセージを出力し、デバッグを容易にします。

4. **エッジケースを特定し、適切に処理する**
    - 想定されるエッジケースに対応するコードを実装します。
    - 必要に応じて、それらのケースのためのテストコードも提案します。

5. **関連するテストを提案する**
    - 提供するコードの動作を検証するためのテストケースを提案します。
    - ユニットテスト、統合テストなど、コードの信頼性を向上させます。

6. **複雑なコードはリファクタリング**
    - 読みにくいコードは、小さく再利用可能な関数やモジュールに分割します。
    - 常に「シンプルさ」を優先します。

7. **インタラクティブな改善提案**
    - 回答の最後には、a. b. などのprefixが付いたリスト形式で次に進むための短い提案を含めます（例：テストケースの追加、コードの最適化、型ヒントの追加）。
    - 次の応答でprefixが指定されたときにはそれに沿った提案を行います。

---

### **ユーザーが使用可能なコマンド**
1. **/start(language?: string)**
   - サポートするプログラミング言語を指定し、支援を開始できます。
   - 例: `/start Python` → Pythonのサポートを開始します。

2. **/help(any_question?: string)**
   - 機能やサポート内容に関するヘルプを表示します。

3. **/fix(any: string)**
   - コードのバグ修正を依頼できます。ユーザーの説明を元にロジカルにコードを分析・改善します。

4. **/quick_fix(any: string)**
   - 簡易的に修正が必要なコードや問題に対処します。詳細な説明はせず、コードのみを提供します。

5. **/explain(any: string)**
   - 提供されたコードやロジックについて、分かりやすく説明します。

6. **/review(any: string)**
   - コードのレビューを実施します。バグの有無、改善案、最適化の提案などを提供します。

]]

local function convert_file_type(file_type)
  if file_type == 'typescriptreact' then
    return 'tsx'
  elseif file_type == 'javascript' then
    return 'typescript'
  end

  return file_type
end

local function count_indent(line)
  local i = 0
  while string.sub(line, i + 1, i + 1):match('%s') do
    i = i + 1
  end
  return i
end

local function remove_common_indent(code)
  local min_indent = nil

  for _, line in ipairs(code) do
    if line ~= '' then
      local indent = count_indent(line)
      if min_indent == nil or indent < min_indent then
        min_indent = indent
      end
    end
  end

  if min_indent ~= nil and min_indent > 0 then
    for i, line in ipairs(code) do
      code[i] = string.sub(line, min_indent + 1)
    end
  end

  return code
end

local function get_code(opts)
  local code = vim.fn.getbufline(opts.bufnr, opts.first_line, opts.last_line)

  return table.concat(remove_common_indent(code), '\n')
end

local function get_diagnostics(opts)
  local diagnostics = vim.diagnostic.get(opts.bufnr)
  local result = {}
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR or diagnostic.severity == vim.diagnostic.severity.WARN then
      if diagnostic.lnum + 1 >= opts.first_line and diagnostic.lnum + 1 <= opts.last_line then
        table.insert(result, diagnostic)
      end
    end
  end

  return result
end

M.find_bugs = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードに問題が見つかったか調べてください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.fix_syntax_error = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードの構文エラーを修正してください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.optimize = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードを最適化してください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.add_comments = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードにコメントを追加してください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.add_tests = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードにテストを実装してください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.explain = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードを説明してください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.split_function = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードを関数に分割してください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.fix_diagnostics = function(opts)
  local diagnostics = get_diagnostics(opts)
  local diagnostics_str = table.concat(
    vim.tbl_map(function(diagnostic)
      return string.format([[- line %d: %s]], diagnostic.lnum - opts.first_line + 2, diagnostic.message)
    end, diagnostics),
    '\n'
  )

  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下の%sコードのDiagnosticsを修正してください。

### Diagnostics

%s

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    diagnostics_str,
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

M.commit_message = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

以下のdiffのコミットメッセージを書いてください。

### Source Code

```%s
%s
```]],
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

local cursor_position_marker = [[{{__cursor__}}]]

M.customize_request = function(opts)
  local code = get_code(opts)
  local text = string.format(
    [[### Question

%s

### Source Code

```%s
%s
```]],
    cursor_position_marker,
    convert_file_type(opts.file_type),
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = convert_file_type(opts.file_type),
  }
end

return M
