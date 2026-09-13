local gitsigns = require("gitsigns")
gitsigns.setup()

local codediff = require("codediff")
codediff.setup({
	diff = {
		layout = "inline",
	},
})
