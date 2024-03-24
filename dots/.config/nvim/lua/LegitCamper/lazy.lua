require("lazy").setup({
	{
		"nvim-telescope/telescope.nvim", tag = "0.1.2",
		dependencies = { "nvim-lua/plenary.nvim" }
	},
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "nvim-treesitter/nvim-treesitter" },
	{
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {                                      -- Optional
                'williamboman/mason.nvim',
                build = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'L3MON4D3/LuaSnip'},     -- Required
        }
    },
    { "ThePrimeagen/harpoon" },
    { "folke/trouble.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
    { "gennaro-tedesco/nvim-peekup" },
    { "Bekaboo/deadcolumn.nvim" },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
        }
    },
    { "windwp/nvim-autopairs", event = "InsertEnter" },
    { "lewis6991/gitsigns" },
    { "lukas-reineke/indent-blankline.nvim" },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
    },
    { "NvChad/ui" },
    {
        "romgrk/barbar.nvim",
        dependencies = {
            "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
            "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
        },
        init = function() 
            vim.g.barbar_auto_setup = false 
        end,
    },
    { "RRethy/vim-illuminate" }, 
    { "epwalsh/obsidian.nvim" },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        
    	}
    },
    { "folke/twilight.nvim" },
    { "folke/zen-mode.nvim" },
    { "folke/flash.nvim" }, 
    { "mrjones2014/legendary.nvim" }, 
    { "saecki/crates.nvim" },
    { "karb94/neoscroll.nvim"  }, 
    { "shortcuts/no-neck-pain.nvim" },
    { "mbbill/undotree" },
    { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    { "antonk52/bad-practices.nvim" },
    { "max397574/better-escape.nvim" },
    { "wakatime/vim-wakatime" },

}, {
	checker = {
		enabled = true, 
    		concurrency = nil, ---@type number? set to 1 to check for updates very slowly
    		notify = true, -- get a notification when new updates are found
    		frequency = 3600, -- check for updates every hour
  	},
	change_detection = {
	enabled = true,
	notify = true, -- get a notification when changes are found
	},
	custom_keys = {
		["<Space>l"] = function()
		lazy = require("lazy.home")
		lazy.home()
		print("ufasdjfl")
		end,
	}
})



