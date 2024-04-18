return {
  "folke/zen-mode.nvim",
  opts = function()
    vim.keymap.set(
      "n",
      "<leader>zz",
      ":lua require('zen-mode').toggle({window={width=.5}})<cr>",
      { desc = "Toggle ZenMode", silent = true }
    )
  end,
}
