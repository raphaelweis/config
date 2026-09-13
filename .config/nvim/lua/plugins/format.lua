vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
	},
})
vim.keymap.set({ "n", "v" }, "<leader>fm", conform.format, { desc = "Format buffer with Conform" })
