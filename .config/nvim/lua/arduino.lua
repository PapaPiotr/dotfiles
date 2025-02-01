local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local conf = require('telescope.config').values

local settings_file = vim.fn.stdpath("config") .. "/arduino_settings.json"
local arduino_settings = {}

local function save_settings(settings)
    local f = io.open(settings_file, "w")
    if f then
        f:write(vim.fn.json_encode(settings))
        f:close()
    end
end

local function load_settings()
    local f = io.open(settings_file, "r")
    if f then
        local content = f:read("*all")
        f:close()
        return vim.fn.json_decode(content)
    end
    arduino_settings.port = "/dev/ttyUSB0"
    arduino_settings.board = "arduino:avr:nano"
    save_settings(arduino_settings)
end

_G.listall_arduino_boards = function()
    local handle = io.popen("arduino-cli board listall")
    local result = handle:read("*a")
    handle:close()

    local lines = {}
    for line in result:gmatch("[^\r\n]+") do
        if line:find(":") then
            table.insert(lines, line)
        end
    end

    pickers.new({}, {
        prompt_title = "Select Arduino Board",
        finder = finders.new_table {
            results = lines,
        },
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                arduino_settings.board = selection.value:match("%S+:%S+:%S+")
                print("Selected board: " .. arduino_settings.board)
                print(" ")
            end)
            save_settings(arduino_settings) -- Sauvegarde des paramètres
            return true
        end,
    }):find()
end

_G.list_arduino_boards = function()
    local handle = io.popen("arduino-cli board list")
    local result = handle:read("*a")
    handle:close()

    local lines = {}
    for line in result:gmatch("[^\r\n]+") do
        if line:match("No boards found.") then
            print("No boards found.")
        else
            if line:match("/%S+/") then
                table.insert(lines, line)
                pickers.new({}, {
                    prompt_title = "Select Arduino Board",
                    finder = finders.new_table {
                        results = lines,
                    },
                    sorter = conf.generic_sorter({}),
                    attach_mappings = function(prompt_bufnr, map)
                        actions.select_default:replace(function()
                            actions.close(prompt_bufnr)
                            local selection = action_state.get_selected_entry()
                            vim.g.selected_board = selection.value
                            arduino_settings.port = selection.value:match("/%S+/%S+")
                            if selection.value:match("%S+:%S+:%S+") then
                                arduino_settings.board = selection.value:match("%S+:%S+:%S+")
                            end

                            print("Selected board: " .. vim.g.selected_board)
                            print(" ")
                        end)
                        save_settings(arduino_settings) -- Sauvegarde des paramètres
                        return true
                    end,
                }):find()
            end
        end
    end
end

arduino_settings = load_settings()

vim.api.nvim_create_user_command("ArduinoConfig", function()
    local port = vim.fn.input("Enter serial port: ", arduino_settings.port)
    local board = vim.fn.input("Enter board fqbn: ", arduino_settings.board)
    arduino_settings.port = port
    arduino_settings.board = board
    save_settings(arduino_settings) -- Sauvegarde des paramètres
    print("Arduino configuration updated!")
end, {})

vim.api.nvim_create_user_command('ArduinoBuild', function()
    vim.cmd('w')
    vim.cmd('belowright split')
    local height = vim.fn.winheight(0) * 0.6 -- Calcule 30% de la hauteur de l'écran
    vim.cmd('resize ' .. math.floor(height)) -- Redimensionne le split à 30% de la hauteur
    vim.cmd('term arduino-cli compile --fqbn ' .. arduino_settings.board .. ' %')
    vim.cmd('setlocal nonumber norelativenumber')
    vim.cmd('startinsert')
end, {})

vim.api.nvim_create_user_command('ArduinoUpload', function()
    vim.cmd('belowright split')
    local height = vim.fn.winheight(0) * 0.6 -- Calcule 30% de la hauteur de l'écran
    vim.cmd('resize ' .. math.floor(height)) -- Redimensionne le split à 30% de la hauteur
    vim.cmd('term arduino-cli compile --fqbn ' .. arduino_settings.board .. ' % && arduino-cli upload -p ' .. arduino_settings.port .. ' --fqbn ' .. arduino_settings.board .. ' %')
    vim.cmd('setlocal nonumber norelativenumber')
    vim.cmd('startinsert')

end, {})

vim.api.nvim_create_user_command('ArduinoMonitor', function()
    vim.cmd('belowright vsplit')
    local width = vim.fn.winwidth(0) * 0.8 -- Calcule 30% de la hauteur de l'écran
    vim.cmd('vertical resize ' .. math.floor(width)) -- Redimensionne le split à 30% de la hauteur
    vim.cmd('term arduino-cli monitor -p ' .. arduino_settings.port)
    vim.cmd('setlocal nonumber norelativenumber')
    vim.cmd('startinsert')
end, {})

vim.api.nvim_create_user_command('ArduinoStatus', function ()
    print(arduino_settings.port)
    print(arduino_settings.board)
end, {})

vim.api.nvim_set_keymap("n", "<leader>all", ":lua listall_arduino_boards()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>al", ":lua list_arduino_boards()<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>af", ":ArduinoConfig<CR>")
vim.keymap.set("n", "<leader>ab", ":ArduinoBuild<CR>")
vim.keymap.set("n", "<leader>au", ":ArduinoUpload<CR>")
vim.keymap.set("n", "<leader>am", ":ArduinoMonitor<CR>")
vim.keymap.set("n", "<leader>as", ":ArduinoStatus<CR>")
