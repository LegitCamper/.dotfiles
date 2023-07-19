local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Space>f', builtin.find_files, {})
vim.keymap.set('n', '<Space>g', builtin.live_grep, {})
vim.keymap.set('n', '<Space>/', function() 
	builtin.grep_string({ search = vim.fn.input("global-search: ")});
end)

