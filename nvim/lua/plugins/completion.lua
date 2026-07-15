-- =============================================================================
-- Completion: Autocomplete As You Type
-- =============================================================================
-- nvim-cmp provides VS Code-like autocomplete:
--   • Suggests functions, variables, snippets as you type
--   • Shows documentation for each suggestion
--   • Tab/Shift-Tab to navigate, Enter to confirm
--   • Ctrl+Space to manually trigger completions
-- =============================================================================

return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- Only load when you start typing
    dependencies = {
      -- Completion sources (where suggestions come from):
      "hrsh7th/cmp-nvim-lsp",   -- Suggestions from LSP (functions, variables)
      "hrsh7th/cmp-buffer",     -- Words from the current file
      "hrsh7th/cmp-path",       -- File paths (type ./ to see files)
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      "hrsh7th/cmp-cmdline",    -- Command line suggestions

      -- Snippet engine + pre-made snippets
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp", -- For regex-based snippets
        dependencies = {
          -- A big collection of ready-made snippets (like VS Code snippets)
          "rafamadriz/friendly-snippets",
        },
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          
          local ls = require("luasnip")
          local s = ls.snippet
          local t = ls.text_node
          local i = ls.insert_node
          local fmt = require("luasnip.extras.fmt").fmt
          
          -- Custom dynamic snippets for Competitive Programming
          ls.add_snippets("cpp", {
            s("for", fmt([[
              for (int {} = 0; {} < {}; {}++) {{
                {}
              }}
            ]], { i(1, "i"), require("luasnip.extras").rep(1), i(2, "n"), require("luasnip.extras").rep(1), i(3) })),
            
            s("bfs", fmt([[
              queue<int> q;
              vector<bool> visited({}, false);
              
              q.push({});
              visited[{}] = true;
              
              while (!q.empty()) {{
                int u = q.front();
                q.pop();
                
                for (int v : adj[u]) {{
                  if (!visited[v]) {{
                    visited[v] = true;
                    q.push(v);
                  }}
                }}
              }}
            ]], { i(1, "n + 1"), i(2, "start_node"), require("luasnip.extras").rep(2) })),
            
            s("segtree", fmt([[
              struct SegTree {{
                int n;
                vector<long long> tree;
                
                SegTree(int _n) : n(_n) {{
                  tree.assign(4 * n + 1, 0);
                }}
                
                void build(int node, int start, int end, const vector<int>& arr) {{
                  if (start == end) {{
                    tree[node] = arr[start];
                    return;
                  }}
                  int mid = start + (end - start) / 2;
                  build(2 * node, start, mid, arr);
                  build(2 * node + 1, mid + 1, end, arr);
                  tree[node] = tree[2 * node] + tree[2 * node + 1];
                }}
                
                long long query(int node, int start, int end, int l, int r) {{
                  if (r < start || end < l) return 0;
                  if (l <= start && end <= r) return tree[node];
                  int mid = start + (end - start) / 2;
                  return query(2 * node, start, mid, l, r) + query(2 * node + 1, mid + 1, end, l, r);
                }}
                
                void update(int node, int start, int end, int idx, int val) {{
                  if (start == end) {{
                    tree[node] = val;
                    return;
                  }}
                  int mid = start + (end - start) / 2;
                  if (start <= idx && idx <= mid)
                    update(2 * node, start, mid, idx, val);
                  else
                    update(2 * node + 1, mid + 1, end, idx, val);
                  tree[node] = tree[2 * node] + tree[2 * node + 1];
                }}
              }};
            ]], {})),
          })
        end,
      },

      -- VS Code-like icons in the completion menu (function, variable, class icons)
      "onsails/lspkind.nvim",
    },

    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        -- Tell cmp to use LuaSnip for snippets
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Make the completion menu look nice with icons
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",  -- Show icon + text (e.g., "ƒ Function")
            maxwidth = 50,         -- Don't let entries get too wide
            ellipsis_char = "...", -- Truncate long entries
          }),
        },

        -- ── Keybindings for the Completion Menu ────────────────────────
        mapping = cmp.mapping.preset.insert({
          -- Ctrl+Space: Manually trigger completions
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Enter: Confirm the selected completion
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          -- Ctrl+e: Close the completion menu
          ["<C-e>"] = cmp.mapping.abort(),

          -- Scroll through documentation preview
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Tab: Smart behavior
          --   1. If menu is open → select next item
          --   2. If inside a snippet → jump to next placeholder
          --   3. Otherwise → regular Tab
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Shift+Tab: Reverse of Tab
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- ── Where Completions Come From ────────────────────────────────
        -- Order matters! LSP suggestions appear first, then snippets,
        -- then words from the buffer, then file paths.
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- Language server suggestions
          { name = "luasnip" },   -- Snippet suggestions
        }, {
          { name = "buffer" },    -- Words from current file
          { name = "path" },      -- File paths
        }),

        -- Make the completion window look nice
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
      })

      -- ── Command Line Completion ────────────────────────────────────
      -- Use buffer source for `/` and `?`
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' }
        }
      })

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' }
        }, {
          { name = 'cmdline' }
        }),
        matching = { disallow_symbol_nonprefix_matching = false }
      })
    end,
  },
}
