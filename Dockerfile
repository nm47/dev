FROM cfs_base

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    sudo \
    python3-pip \
    python3-setuptools \
    xclip \
    cmake \
    build-essential \
    unzip \
    curl \
    ripgrep \
    git \
    clangd \
    tree \
    clang-format \
    fd-find \
    iputils-ping \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Neovim and fzf
RUN \
    # Install Neovim
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    tar -C /opt -xzf nvim-linux64.tar.gz && \
    rm nvim-linux64.tar.gz && \
    ln -s /opt/nvim-linux64/bin/nvim /usr/bin/nvim && \
    \
    git clone https://github.com/nm47/dotfiles.git ~/.config && \
    nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonUpdate" +qa && \
    nvim --headless "+TSUpdateSync" +qa && \
    update-alternatives --install /usr/bin/editor editor /opt/nvim-linux64/bin/nvim 60 && \
    \
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --all


# Configure bash and setup dotfiles
RUN \
    # Configure bash
    curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh && \
    echo "set -o vi" >> ~/.bashrc && \
    echo "alias vim='nvim'" >> ~/.bashrc && \
    echo "alias grep='rg'" >> ~/.bashrc && \
    echo "source ~/.fzf.bash" >> ~/.bashrc && \
    echo "source ~/.git-prompt.sh" >> ~/.bashrc && \
    echo "export GIT_PS1_SHOWDIRTYSTATE=1" >> ~/.bashrc && \
    echo "export PS1='\\[\\033[01;32m\\]\u@\\h:\\[\\033[01;34m\\]\W\\[\\033[0m\\]\$(__git_ps1 \"\\[\\033[0;91m\\][%s]\\[\\033[0m\\]\")\$ '" >> ~/.bashrc
    
CMD ["bash"]

