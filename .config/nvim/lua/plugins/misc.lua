-- Plugins that require only 1 line of config that don't fit in a specific category
local lualine = require("lualine")
lualine.setup({})

local nvim_autopairs = require("nvim-autopairs")
nvim_autopairs.setup({})

local codediff = require("codediff")
codediff.setup({
	diff = {
		layout = "inline",
	},
})

local oil = require("oil")
oil.setup({
	view_options = {
		show_hidden = true,
	},
})
vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Open oil pane" })
