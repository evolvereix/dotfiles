return {
  {
    "marko-cerovac/material.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      -- 匹配终端 Ghostty 的 Anthracite 主题（Material Deep Ocean 调色板）
      vim.g.material_style = "deep ocean"
    end,
    opts = {
      contrast = {
        floating_windows = true,
        sidebars = true,
      },
      plugins = {
        "gitsigns",
        "nvim-cmp",
        "nvim-web-devicons",
        "trouble",
        "which-key",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "material" },
  },
}
