{
  programs.nixvim.extraConfigLua = ''
    -- Ctrl+hjkl across nvim splits and herdr panes (paulbkim-dev/vim-herdr-navigation).
    -- Outside herdr it falls back to plain wincmd.
    local function herdr_nav(wincmd, dir)
      local prev = vim.api.nvim_get_current_win()
      vim.cmd("wincmd " .. wincmd)
      if vim.api.nvim_get_current_win() ~= prev then
        return
      end
      local pane = vim.env.HERDR_PANE_ID
      if pane and pane ~= "" then
        local herdr = vim.env.HERDR_BIN_PATH
        if herdr == nil or herdr == "" then
          herdr = "herdr"
        end
        vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--pane", pane })
      end
    end

    for key, spec in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
      vim.keymap.set("n", "<C-" .. key .. ">", function()
        herdr_nav(key, spec)
      end, { silent = true, noremap = true, desc = "Navigate " .. spec .. " (nvim/herdr)" })
    end
  '';
}
