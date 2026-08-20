return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewRefresh" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview (working tree)" },
      { "<leader>gD", "<cmd>DiffviewOpen origin/master...HEAD<cr>", desc = "Diffview (branch vs master)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File history (all)" },
      { "<leader>gx", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    opts = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "DiffviewFiles", "DiffviewFileHistory" },
        callback = function(args)
          vim.keymap.set("n", "<LeftMouse>", function()
            local actions = require("diffview.actions")
            actions.select_entry()
          end, { buffer = args.buf })
        end,
      })
      return {}
    end,
  },
}
