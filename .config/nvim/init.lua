-- Options
vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.swapfile = false
vim.opt.signcolumn = "yes"
vim.opt.undofile = true
vim.opt.colorcolumn = "80"
vim.opt.foldenable = false
vim.opt.showmode = false
vim.opt.clipboard:append("unnamedplus")
vim.opt.fillchars:append({ diff = " " })

-- Keymaps
vim.keymap.set("n", "<ESC>", "<CMD>noh<CR>")

-- Pack
local hooks = {
	["telescope-fzf-native.nvim"] = function(ev)
		vim.system({ "make" }, { cwd = ev.data.path }):wait()
	end,
	["nvim-treesitter"] = function(ev)
		if not ev.data.active then
			vim.cmd.packadd("nvim-treesitter")
		end
		vim.cmd("TSUpdate")
	end,
}
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind == "install" or kind == "update" then
			local hook = hooks[name]
			if hook then
				vim.schedule(function()
					local ok, err = pcall(hook, ev)
					if not ok then
						vim.notify("Build hook failed for " .. name .. ":\n" .. tostring(err), vim.log.levels.ERROR)
					else
						vim.notify("Build hook completed for " .. name, vim.log.levels.INFO)
					end
				end)
			end
		end
	end,
})
vim.pack.add({
	"https://github.com/ellisonleao/gruvbox.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/stevearc/conform.nvim",
	{ src = "https://github.com/Saghen/blink.cmp", version = vim.version.range("*") },
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	-- "https://github.com/barrettruth/diffs.nvim",
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = vim.version.range("3") },
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/dlyongemallo/diffview.nvim",
	"https://github.com/romgrk/barbar.nvim",
	"https://github.com/rickhowe/diffchar.vim",
})

-- Colorscheme setup
require("gruvbox").setup({
	italic = {
		strings = false,
		emphasis = false,
		comments = false,
		operators = false,
		folds = false,
	},
	contrast = "hard",
})
vim.cmd("colorscheme gruvbox")

-- Telescope
local telescope = require("telescope")
telescope.setup({
	pickers = {
		find_files = {
			file_ignore_patterns = { "node_modules", ".git", ".venv", ".terraform" },
			hidden = true,
		},
	},
})
telescope.load_extension("fzf")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })

-- Autopairs
require("nvim-autopairs").setup()

--Conform
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff" },
		javascript = { "prettierd" },
		typescript = { "prettierd" },
		javascriptreact = { "prettierd" },
		typescriptreact = { "prettierd" },
		css = { "prettierd" },
		markdown = { "prettierd" },
		yaml = { "prettierd" },
		nix = { "nixfmt" },
		cpp = { "clang-format" },
		c = { "clang-format" },
		terraform = { "terraform_fmt" },
	},
})
vim.keymap.set({ "n", "v" }, "<leader>fm", conform.format)

-- Blink.cmp
require("blink.cmp").setup({
	completion = { documentation = { auto_show = true } },
	sources = {
		default = { "lsp", "path", "buffer" },
	},
})

-- LSP
vim.lsp.enable({
	"lua_ls",
	"nixd",
	"vtsls",
	"eslint",
	"cssls",
	"html",
	"pyright",
	"tailwindcss",
	"clangd",
	"terraformls",
})

vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					-- '${3rd}/luv/library',
					-- '${3rd}/busted/library',
				},
			},
		})
	end,
	settings = {
		Lua = {},
	},
})
vim.lsp.config("eslint", {
	settings = {
		quiet = false,
	},
})

-- Treesitter
require("nvim-treesitter").install({
	"lua",
	"nix",
	"markdown",
	"markdown_inline",
	"typescript",
	"javascript",
	"tsx",
	"jsx",
	"python",
	"c",
	"cpp",
	"terraform",
})

-- Oil
require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})
vim.keymap.set("n", "<leader>E", "<CMD>Oil<CR>")

-- Neo-tree
require("neo-tree").setup({
	filesystem = {
		filtered_items = {
			visible = true,
			hide_dotfiles = false,
		},
	},
})
vim.keymap.set("n", "<leader>e", "<CMD>Neotree toggle<CR>")

-- Gitsigns
local gitsigns = require("gitsigns")
gitsigns.setup({
	signs = {
		add = { text = "▌" },
		change = { text = "▌" },
		delete = { text = "▌" },
		topdelete = { text = "▌" },
		changedelete = { text = "▌" },
		untracked = { text = "▌" },
	},
	signs_staged = {
		add = { text = "▌" },
		change = { text = "▌" },
		delete = { text = "▌" },
		topdelete = { text = "▌" },
		changedelete = { text = "▌" },
		untracked = { text = "▌" },
	},
})

-- Lualine
require("lualine").setup()

-- diffview.nvim
require("diffview").setup({
	view = {
		foldlevel = 99,
	},
})
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = "diff",
	callback = function()
		vim.schedule(function()
			vim.api.nvim_set_hl(0, "dcDiffText", {})
		end)
	end,
})
vim.keymap.set("n", "<leader>gr", "<CMD>DiffviewToggle<CR>")

-- barbar.nvim
require("barbar").setup({
	animation = false,
})
