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
      "hrsh7th/cmp-nvim-lsp-signature-help", -- Parameter hints while typing function arguments
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
          local rep = require("luasnip.extras").rep
          local fmt = require("luasnip.extras.fmt").fmt
          
          -- ── C++ Snippets ──────────────────────────────────────────────
          ls.add_snippets("cpp", {
            s("for", fmt([[
              for (int {} = 0; {} < {}; {}++) {{
                {}
              }}
            ]], { i(1, "i"), rep(1), i(2, "n"), rep(1), i(3) })),
            
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
            ]], { i(1, "n + 1"), i(2, "start_node"), rep(2) })),
            
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

            s("dsu", fmt([[
              struct DSU {{
                vector<int> parent, rank;
                DSU(int n) : parent(n + 1), rank(n + 1, 0) {{
                  iota(parent.begin(), parent.end(), 0);
                }}
                int find(int x) {{
                  return parent[x] == x ? x : parent[x] = find(parent[x]);
                }}
                bool unite(int a, int b) {{
                  a = find(a); b = find(b);
                  if (a == b) return false;
                  if (rank[a] < rank[b]) swap(a, b);
                  parent[b] = a;
                  if (rank[a] == rank[b]) rank[a]++;
                  return true;
                }}
              }};
            ]], {})),

            s("mint", fmt([[
              struct Mint {{
                long long val;
                static constexpr long long MOD = {};
                Mint(long long v = 0) : val((v % MOD + MOD) % MOD) {{}}
                Mint operator+(const Mint& o) const {{ return Mint(val + o.val); }}
                Mint operator-(const Mint& o) const {{ return Mint(val - o.val); }}
                Mint operator*(const Mint& o) const {{ return Mint(val * o.val); }}
                Mint power(long long b) const {{
                  Mint res(1), base(val);
                  while (b > 0) {{ if (b & 1) res = res * base; base = base * base; b >>= 1; }}
                  return res;
                }}
                Mint operator/(const Mint& o) const {{ return *this * o.power(MOD - 2); }}
              }};
            ]], { i(1, "998244353") })),

            s("fenwick", fmt([[
              struct Fenwick {{
                int n;
                vector<long long> tree;
                Fenwick(int _n) : n(_n), tree(n + 1, 0) {{}}
                void update(int idx, long long delta) {{
                  for (; idx <= n; idx += idx & (-idx)) tree[idx] += delta;
                }}
                long long query(int idx) {{
                  long long sum = 0;
                  for (; idx > 0; idx -= idx & (-idx)) sum += tree[idx];
                  return sum;
                }}
                long long query(int l, int r) {{ return query(r) - query(l - 1); }}
              }};
            ]], {})),
          })

          -- ── Python Snippets ───────────────────────────────────────────
          ls.add_snippets("python", {
            s("main", fmt([[
              def main():
                  {}

              if __name__ == "__main__":
                  main()
            ]], { i(1, "pass") })),

            s("dc", fmt([[
              @dataclass
              class {}:
                  {}: {}
            ]], { i(1, "ClassName"), i(2, "field"), i(3, "str") })),

            s("tc", fmt([[
              class Test{}(unittest.TestCase):
                  def test_{}(self):
                      {}
            ]], { i(1, "Name"), i(2, "case"), i(3, "pass") })),
          })

          -- ── LaTeX Snippets ────────────────────────────────────────────
          ls.add_snippets("tex", {
            s("beg", fmt([[
              \begin{{{}}}
                {}
              \end{{{}}}
            ]], { i(1, "environment"), i(2), rep(1) })),

            s("fig", fmt([[
              \begin{{figure}}[{}]
                \centering
                \includegraphics[width={}\textwidth]{{{}}}
                \caption{{{}}}
                \label{{fig:{}}}
              \end{{figure}}
            ]], { i(1, "htbp"), i(2, "0.8"), i(3, "image"), i(4, "Caption"), i(5, "label") })),

            s("eq", fmt([[
              \begin{{equation}}
                {}
                \label{{eq:{}}}
              \end{{equation}}
            ]], { i(1), i(2, "label") })),

            s("ali", fmt([[
              \begin{{align}}
                {} &= {} \\\\
                {} &= {}
              \end{{align}}
            ]], { i(1), i(2), i(3), i(4) })),
          })

          -- ── Markdown Snippets ─────────────────────────────────────────
          ls.add_snippets("markdown", {
            s("cb", fmt([[
              ```{}
              {}
              ```
            ]], { i(1, "language"), i(2) })),
            s("task", t("- [ ] ")),
            s("tbl", fmt([[
              | {} | {} |
              |---|---|
              | {} | {} |
            ]], { i(1, "Header 1"), i(2, "Header 2"), i(3), i(4) })),
            s("link", fmt("[{}]({})", { i(1, "text"), i(2, "url") })),
          })

          -- ── Shell / Bash Snippets ─────────────────────────────────────
          ls.add_snippets("sh", {
            s("shebang", t("#!/usr/bin/env bash")),
            s("strict", t({ "set -euo pipefail", "IFS=$'\\n\\t'" })),
            s("fn", fmt([[
              {}() {{{{
                local {}="$1"
                {}
              }}}}
            ]], { i(1, "function_name"), i(2, "arg"), i(3, "# body") })),
            s("if", fmt([[
              if [ {} ]; then
                {}
              fi
            ]], { i(1, "condition"), i(2) })),
            s("forfile", fmt([[
              while IFS= read -r {}; do
                {}
              done < "{}"
            ]], { i(1, "line"), i(2), i(3, "file.txt") })),
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
          { name = "nvim_lsp_signature_help" }, -- Parameter hints
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
