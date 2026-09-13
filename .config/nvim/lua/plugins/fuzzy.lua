local telescope = require("telescope")
local builtin = require("telescope.builtin")

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<C-u>"] = false,
			},
		},
	},
})
telescope.load_extension("fzf")

vim.keymap.set("n", "<leader>ff", function()
	builtin.find_files({ hidden = true })
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
