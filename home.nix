{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "pedrocunha";
  home.homeDirectory = "/home/pedrocunha";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # System utilities
    openssh # secure shell protocol
    which # locate executables
    git # version control system
    cacert # certificate authority certificates
    tzdata # time zone database
    hostname # set or print name of current host system
    dig # DNS lookup utility
    htop # interactive process viewer
    iotop # top-like utility for disk I/O
    ncdu # disk usage analyzer

    # File management and navigation
    yazi # terminal file manager
    broot # interactive tree view file manager
    tree # display directory contents in a tree-like format
    rclone # sync files and directories to cloud storage

    # Text processing and editing
    neovim # highly configurable text editor
    vim # text editor
    jq # command-line JSON processor
    delta # syntax-highlighting pager for git

    # Shell and terminal enhancements
    zsh # extended Bourne shell
    starship # customizable prompt for any shell
    zellij # terminal multiplexer
    atuin # magical shell history
    fzf # command-line fuzzy finder
    bat # cat clone with syntax highlighting
    lsd # modern ls command
    thefuck # magnificent app which corrects your previous console command

    # Network utilities
    curl # transfer data using various protocols
    wget # retrieve files using HTTP, HTTPS, and FTP
    netcat-gnu # networking utility for reading/writing network connections
    twingate # access to asq resourcesc

    # Development tools
    nix-direnv # direnv integration for Nix
    direnv # directory-based environment variable manager
    just # command runner for project-specific tasks
    rye # Python project management tool
    nodejs_22 # JavaScript runtime
    sqlite # SQL database engine

    # Text search and manipulation
    ripgrep # fast searching tool

    # Clipboard management
    xsel # X11 selection and clipboard manipulation

    # File compression
    unzip # extract compressed files

    # Navigation enhancement
    zoxide # smarter cd command

    # GitHub CLI
    gh # GitHub command-line tool

    # Multimedia
    ffmpeg # audio and video converter

    # Fonts
    pkgs.nerdfonts # patched fonts for developers
  ];

  programs.git = {
    enable = true;
    userName = "pedro.cunha";
    userEmail = "pedro.cunha@asq.capital";
    extraConfig = {
      credential."https://github.com" = {
        helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      credential."https://gist.github.com" = {
        helper = "!${pkgs.gh}/bin/gh auth git-credential";
      };
      push = {
        default = "current";
      };
      core = {
        pager = "delta";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      delta = {
        navigate = true;
      };
      merge = {
        conflictStyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = false;
      share = true;
      extended = false;
    };

    oh-my-zsh = {
      enable = true;
      plugins = ["git" "docker" "sudo"];
      theme = "robbyrussell";
    };

    initExtra = ''
      # Additional Zsh configuration
      export NIX_SHELL=True

      # Load aliases
      if [ -f $HOME/.config/home-manager/.zshrc_aliases ]; then
        . $HOME/.config/home-manager/.zshrc_aliases
      fi

      # History options
      setopt HIST_FCNTL_LOCK
      unsetopt HIST_EXPIRE_DUPS_FIRST
      setopt SHARE_HISTORY
      unsetopt EXTENDED_HISTORY

      HISTDUP=erase
      setopt appendhistory
      setopt sharehistory
      setopt hist_ignore_space
      setopt hist_ignore_all_dups
      setopt hist_save_no_dups

      # Completion settings
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      # Key bindings
      bindkey -e 
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      # Custom
      function yy() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      # Custom Config
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"
      eval "$(atuin init zsh)"
      eval "$(fzf --zsh)"
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
      eval $(thefuck --alias)

      if [ -d ~/.config/home-manager ] && [ "$(ls -A ~/.config/home-manager/.exports* 2>/dev/null)" ]; then
          for export_file in ~/.config/home-manager/.exports*; do
              if [[ -f "$export_file" && -r "$export_file" ]]; then
                  source "$export_file"
              fi
          done
      fi

      export DIRENV_LOG_FORMAT="$(printf "\033[2mdirenv: %%s\033[0m")"

      _direnv_hook() {
        unalias egrep && eval "$(direnv export zsh 2> >(egrep -v -e '^....direnv: export' >&2))"
      };

      eval "$(direnv hook bash)"

      if [ -f .envrc ]; then
          direnv allow
          _direnv_hook
      fi
    '';
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/pedrocunha/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = {
    NIX_SESSION = "True";
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "brave";
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}