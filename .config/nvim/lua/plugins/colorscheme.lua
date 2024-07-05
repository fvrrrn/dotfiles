return {
  {
    "mcchrish/zenbones.nvim",
    dependencies = {
      "rktjmp/lush.nvim",
    },
    config = function()
-- Apply custom highlights on colorscheme change.
-- Must be declared before executing ':colorscheme'.
grpid = vim.api.nvim_create_augroup('custom_highlights', {})
vim.api.nvim_create_autocmd('ColorScheme', {
  group = grpid,
  pattern = '*bones',
  command = 'hi Comment  gui=NONE |' ..
            'hi Constant gui=NONE'
})
      vim.api.nvim_command("colorscheme zenbones")
    end,
  },
}
