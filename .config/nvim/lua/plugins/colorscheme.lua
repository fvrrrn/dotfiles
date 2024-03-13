return {
  {
    "mcchrish/zenbones.nvim",
    dependencies = {
      "rktjmp/lush.nvim",
    },
    config = function()
      vim.api.nvim_command("colorscheme zenbones")
    end,
  },
}
