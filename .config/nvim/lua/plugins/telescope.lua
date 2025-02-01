return {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
	    local telescope = require("telescope")
	    local actions = require("telescope.actions")

	    telescope.setup({
		    defaults = {
			    -- Your other Telescope configuration goes here, for example:
			    prompt_prefix = ">",
			    selection_caret = " ",
			    layout_config = {
				    width = 0.75,
				    height = 0.5,
			    },
		    },
	    })


	    -- Set up keymaps for launching Telescope pickers:
	    vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })
	    vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { noremap = true, silent = true })
	    vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { noremap = true, silent = true })
	    vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { noremap = true, silent = true })
  end,
  }
