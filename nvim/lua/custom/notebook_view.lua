local M = {}

local function source_lines(cell)
  local source = cell.source or {}
  if type(source) == "string" then
    return vim.split(source, "\n", { plain = true })
  end

  local lines = {}
  for _, line in ipairs(source) do
    line = line:gsub("\n$", "")
    table.insert(lines, line)
  end
  return lines
end

local function output_summary(cell)
  local outputs = cell.outputs or {}
  if #outputs == 0 then return {} end

  local lines = { "", "> Output: " .. tostring(#outputs) .. " item" .. (#outputs == 1 and "" or "s") }
  for _, output in ipairs(outputs) do
    if output.name and output.text then
      local text = type(output.text) == "table" and table.concat(output.text, "") or output.text
      local first = vim.split(text, "\n", { plain = true })[1] or ""
      if first ~= "" then
        table.insert(lines, "> " .. first)
      end
    elseif output.output_type then
      table.insert(lines, "> " .. output.output_type)
    end
  end
  return lines
end

function M.render_file(path)
  local raw = table.concat(vim.fn.readfile(path), "\n")
  local ok, notebook = pcall(vim.json.decode, raw)
  if not ok or type(notebook) ~= "table" or type(notebook.cells) ~= "table" then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(raw, "\n", { plain = true }))
    vim.bo.filetype = "json"
    return
  end

  local rendered = {
    "<!-- Notebook preview: readable view generated from " .. vim.fn.fnamemodify(path, ":t") .. " -->",
    "<!-- Use :NotebookOpenRaw to edit raw JSON, or install jupytext for round-trip Markdown editing. -->",
    "",
  }

  for index, cell in ipairs(notebook.cells) do
    local cell_type = cell.cell_type or "unknown"
    table.insert(rendered, "<!-- cell " .. index .. ": " .. cell_type .. " -->")

    if cell_type == "code" then
      table.insert(rendered, "```python")
      vim.list_extend(rendered, source_lines(cell))
      table.insert(rendered, "```")
      vim.list_extend(rendered, output_summary(cell))
    else
      vim.list_extend(rendered, source_lines(cell))
    end

    table.insert(rendered, "")
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, rendered)
  vim.bo.filetype = "markdown"
  vim.bo.buftype = "acwrite"
  vim.bo.swapfile = false
  vim.bo.modified = false
  vim.b.notebook_raw_path = path
  vim.b.notebook_preview = true

  vim.schedule(function()
    pcall(function()
      require("render-markdown").buf_enable()
    end)
  end)
end

function M.setup()
  if vim.fn.executable("jupytext") == 1 then
    return
  end

  local group = vim.api.nvim_create_augroup("NotebookReadableFallback", { clear = true })

  vim.api.nvim_create_autocmd("BufReadCmd", {
    group = group,
    pattern = "*.ipynb",
    callback = function(args)
      M.render_file(args.file)
    end,
  })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    group = group,
    pattern = "*.ipynb",
    callback = function()
      vim.notify(
        "This is a read-only notebook preview. Install jupytext for editable Markdown notebooks, or use :NotebookOpenRaw.",
        vim.log.levels.WARN,
        { title = "Notebook" }
      )
      vim.bo.modified = false
    end,
  })

  vim.api.nvim_create_user_command("NotebookOpenRaw", function()
    local path = vim.b.notebook_raw_path or vim.api.nvim_buf_get_name(0)
    if path == "" then
      vim.notify("No notebook path found", vim.log.levels.WARN, { title = "Notebook" })
      return
    end

    vim.cmd("noautocmd edit " .. vim.fn.fnameescape(path))
    vim.bo.filetype = "json"
  end, { desc = "Open the current notebook as raw JSON" })
end

return M
