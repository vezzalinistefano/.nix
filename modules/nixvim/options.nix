{
  programs = {
    nixvim = {
      clipboard = {
        register = "unnamedplus";
      };
      opts = {
        updatetime = 50;

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
        hlsearch = false;
        incsearch = true;
        inccommand = "split";
        ignorecase = true;
        #   patterns
        smartcase = true;
        #   case characters
        scrolloff = 8;
        cursorline = true;
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
