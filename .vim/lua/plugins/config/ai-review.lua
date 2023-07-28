local M = {}

local code_context = [[You are a very good programmer.

Please reply in Markdown format. When outputting code, enclose
it in code fence with a file type as follows:

```typescript
console.log("Hello")
```

But write the language for the codeblock of TypeScript code including jsx as 'typescript'.

Please answer in Japanese.
]]

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
    opts.file_type,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    diagnostics_str,
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
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
    opts.file_type,
    code
  )

  return {
    context = code_context,
    text = text,
    code = code,
    file_type = opts.file_type,
  }
end

return M
