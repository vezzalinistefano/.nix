{
  programs = {
    nixvim = {
      clipboard = {
        register = "unnamedplus";
        providers.wl-copy.enable = true;
      };
      opts = {
        updatetime = 100;

        relativenumber = true;
        number = true;
        hidden = true;
        mouse = "a";
        mousemodel = "extend";
        splitbelow = true;
        splitright = true;

        colorcolumn = "80";

        swapfile = false;
        modeline = true;
        modelines = 100;
        undofile = true;
        incsearch = true;
        inccommand = "split";
        ignorecase = true;
        #   patterns
        smartcase = true;
        #   case characters
        scrolloff = 8;
        cursorline = false;
        cursorcolumn = false;
        signcolumn = "yes";
        laststatus = 3;
        fileencoding = "utf-8";
        termguicolors = true;
        spell = false;
        wrap = false;

        # Tab options
        tabstop = 4;
        shiftwidth = 4;
        expandtab = true;
        smartindent = true;

        textwidth = 0;
        #   broken after white space to get this width.

        # Folding
        foldlevel = 300;
      };
    };
  };
}
