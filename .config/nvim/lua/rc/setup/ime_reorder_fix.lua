-- Fix input reordering of macOS IME commits in Alacritty.
--
-- Alacritty sends multi-char IME commits as bracketed paste (deferred
-- nvim_paste) while single-char commits (、？ etc.) and plain keys like
-- <CR> arrive as normal key input (fast nvim_input -> typeahead). When
-- typing fast, those keys can be consumed while paste events are still
-- pending, ending up before/inside the previously committed text.
--
-- Design: every deferred input goes through a single FIFO queue drained
-- one item per event-loop tick, so relative order is guaranteed:
--   * Typed multibyte chars (IME commits) are intercepted via vim.on_key,
--     discarded, and enqueued. The vim.schedule'd drain runs after any
--     pending nvim_paste events, restoring wire order.
--   * While the queue is busy, other raw typed keys (key == typed) are
--     enqueued too, so fast follow-up input cannot overtake queued chars.
--     Keys taken by mappings (K_LUA pseudo-keys, mapping RHS expansions:
--     key ~= typed) cannot be deferred safely and stay out of reach.
--   * A typed <CR> cannot be deferred in on_key (Lua-mapped <CR> surfaces
--     as K_LUA, and discarding K_LUA freezes the editor), so the effective
--     insert-mode <CR> mapping is wrapped and its execution is enqueued
--     as a queue item instead.
--
-- Each drained key is fed back with the typed flag and the queue waits
-- until on_key observes its consumption before draining the next item;
-- this keeps queue items ordered even against mapping machinery that
-- feeds keys with the 'i' (insert-in-front) flag, like cmp's fallback.

-- Kill switch for debugging
if vim.env.IME_REORDER_FIX_DISABLE == '1' then
  return
end

local ns = vim.api.nvim_create_namespace('ime_reorder_fix')

-- Debug tracing: set IME_REORDER_FIX_TRACE=/path/to/file to log decisions
local trace = function(_) end
if vim.env.IME_REORDER_FIX_TRACE then
  local tf = assert(io.open(vim.env.IME_REORDER_FIX_TRACE, 'a'))
  trace = function(msg)
    tf:write(msg, '\n')
    tf:flush()
  end
end

local queue = {}
local draining = false
local waiting_key = nil
local waiting_seq = 0
-- `typed` of the most recently dispatched key, observed by on_key. Used by
-- the <CR> wrapper to tell a typed <CR> from one fed by plugin machinery.
local last_typed = ''

-- Insert queued text directly when insert mode was already left (fast
-- <Esc>): feeding it would dump it into normal mode and lose it. Uses
-- nvim_buf_set_text because nvim_put pads with spaces under 'virtualedit'.
local function set_text_rescue(key)
  local b1 = key:byte(1)
  if b1 < 0x20 or b1 == 0x7F or b1 == 0x80 then
    return
  end
  pcall(function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()
    -- Leaving insert parks the cursor on the char left of the former
    -- insert position; append right after that char
    local at = math.min(col, #line)
    local ch = line:sub(at + 1):match('^.[\128-\191]*')
    if ch then
      at = at + #ch
    end
    vim.api.nvim_buf_set_text(0, row - 1, at, row - 1, at, { key })
    vim.api.nvim_win_set_cursor(0, { row, at })
  end)
end

local drain

local function continue_drain()
  waiting_key = nil
  vim.schedule(drain)
end

drain = function()
  local item = table.remove(queue, 1)
  if not item then
    draining = false
    return
  end
  if item.kind == 'cr' then
    trace('drain <CR>')
    item.run(false)
    vim.schedule(drain)
    return
  end
  if not vim.fn.mode():find('^i') then
    trace(('drain key=%s -> set_text rescue (mode=%s)'):format(vim.inspect(item.key), vim.fn.mode()))
    set_text_rescue(item.key)
    vim.schedule(drain)
    return
  end
  waiting_key = item.key
  waiting_seq = waiting_seq + 1
  local seq = waiting_seq
  trace(('drain key=%s'):format(vim.inspect(item.key)))
  -- escape_ks must be true for text: chars like 「、」(E3 80 81) contain a
  -- raw 0x80 byte, which is K_SPECIAL and corrupts typeahead unescaped.
  -- Raw special keys are already in internal form and go unescaped
  vim.api.nvim_feedkeys(item.key, 't', item.escape)
  -- Safety valve: if consumption is never observed, continue anyway so
  -- the queue can not stall permanently
  vim.defer_fn(function()
    if waiting_key == item.key and waiting_seq == seq then
      trace('drain handshake timeout')
      continue_drain()
    end
  end, 200)
end

local function enqueue(item)
  queue[#queue + 1] = item
  if not draining then
    draining = true
    vim.schedule(drain)
  end
end

vim.on_key(function(key, typed)
  last_typed = typed or ''

  -- A key we fed came back: let it through and continue the queue.
  -- Checked first so the handshake also completes outside insert mode
  if waiting_key and key == waiting_key then
    continue_drain()
    return
  end

  if not vim.fn.mode():find('^i') then
    return
  end
  -- Ignore keys not produced by typing (e.g. mapping expansions)
  if typed == nil or typed == '' then
    return
  end
  -- Only raw keys (key == typed) may be deferred. When a mapping expands,
  -- its first result key carries the original `typed` value but must stay
  -- in place: pulling it out of the RHS sequence corrupts the expansion
  -- (e.g. lexima's <Esc> feeding <C-r>=...)
  if key ~= typed then
    return
  end

  local b1 = key:byte(1)
  local intercept, escape
  if b1 >= 0xC2 then
    -- Multibyte text char (UTF-8 lead byte), which is what IME commits
    -- produce: always defer
    intercept, escape = true, true
  elseif draining then
    -- The queue is busy: defer other raw typed keys too, so fast
    -- follow-up input cannot overtake queued chars
    if b1 == 0x80 then
      -- K_SPECIAL + KS_EXTRA (0xFD) pseudo-keys are excluded
      if key:byte(2) ~= 0xFD then
        intercept, escape = true, false
      end
    else
      intercept, escape = true, true
    end
  end
  if not intercept then
    return
  end

  trace(('enqueue key=%s (queue=%d)'):format(vim.inspect(key), #queue + 1))
  enqueue({ kind = 'key', key = key, escape = escape })
  return ''
end, ns)

-- Part 2: defer the effective insert-mode <CR> mapping.

local WRAP_DESC = 'ime_reorder_fix: deferred <CR>'
local CR = vim.keycode('<CR>')

-- The 'i' feedkeys flag inserts before pending typeahead. The synchronous
-- path needs it to preserve the in-place expansion semantics of expr
-- mappings; the deferred (queued) path must NOT use it.
local function feed(keys, remap, in_place)
  vim.api.nvim_feedkeys(keys, (remap and 'm' or 'n') .. (in_place and 'i' or ''), false)
end

local function make_runner(map)
  if vim.tbl_isempty(map) then
    return function(in_place)
      feed(CR, false, in_place)
    end
  end
  if map.callback then
    local cb = map.callback
    local is_expr = map.expr == 1
    local remap = map.noremap ~= 1
    -- Expr mapping results normally get key-notation replacement applied by
    -- the mapping engine; reproduce it when calling the callback manually
    local replace = map.replace_keycodes == 1
    return function(in_place)
      local ok, keys = pcall(cb)
      if not ok then
        feed(CR, false, in_place)
      elseif is_expr and type(keys) == 'string' and keys ~= '' then
        if replace then
          keys = vim.api.nvim_replace_termcodes(keys, true, true, true)
        end
        feed(keys, remap, in_place)
      end
    end
  end
  local keys = vim.api.nvim_replace_termcodes(map.rhs or '<CR>', true, true, true)
  -- Feeding a remappable rhs containing <CR> would recurse into this
  -- wrapper; fall back to noremap in that case
  local remap = map.noremap ~= 1 and not keys:find(CR, 1, true)
  return function(in_place)
    feed(keys, remap, in_place)
  end
end

local function wrap_cr()
  -- Only wrap in regular editing buffers. Special buffers (picker inputs
  -- with buftype=prompt, nofile scratch, etc.) own their <CR> confirm
  -- semantics, and deferring those mappings breaks them (e.g. snacks
  -- picker confirm never firing)
  if vim.bo.buftype ~= '' then
    return
  end
  local map = vim.fn.maparg('<CR>', 'i', false, true)
  if map.desc == WRAP_DESC then
    return
  end
  local run_original = make_runner(map)
  local is_buffer = map.buffer == 1
  vim.keymap.set('i', '<CR>', function()
    if last_typed:find('\r', 1, true) then
      -- Typed Enter: enqueue so it runs after pending paste events and
      -- after previously queued chars
      enqueue({ kind = 'cr', run = run_original })
    else
      -- Part of a plugin-fed key sequence: run in place
      run_original(true)
    end
  end, {
    desc = WRAP_DESC,
    silent = true,
    buffer = is_buffer and 0 or nil,
    nowait = is_buffer,
  })
end

-- Re-check on every InsertEnter: cheap, and self-heals when plugins
-- (lazy-loaded cmp, buffer-local insx rules) install their own mapping
vim.api.nvim_create_autocmd('InsertEnter', {
  group = vim.api.nvim_create_augroup('ime_reorder_fix_cr', {}),
  callback = wrap_cr,
})
