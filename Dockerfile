FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

arg USERNAME=niels

# Deps
RUN apt update && apt install -y \
    sudo \
    python3-pip \
    python3-setuptools \
    xclip \
    cmake \
    build-essential \
    unzip \
    curl \
    ripgrep \
    git && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    #pip3 install pynvim

# Clone and build Neovim
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz && \
    sudo rm -rf /opt/nvim && \
    sudo tar -C /opt -xzf nvim-linux64.tar.gz

# Set Neovim as the default editor
RUN update-alternatives --install /usr/bin/editor editor /opt/nvim-linux64/bin/nvim 60

# install dev env tools
RUN apt update && apt install -y \
    xclip \
    clangd \
    tree \
    clang-format \
    wget && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create dev user
RUN useradd -m -s /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

WORKDIR /home/$USERNAME/
USER $USERNAME

# Install fzf
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    ~/.fzf/install --all

RUN echo "set -o vi" >> /home/$USERNAME/.bashrc && \
    echo "alias vim='nvim'" >> /home/$USERNAME/.bashrc && \
    echo "source ~/.fzf.bash" >> /home/$USERNAME/.bashrc && \
    echo "export PATH=\"$PATH:/opt/nvim-linux64/bin\"" >> /home/$USERNAME/.bashrc

RUN git clone https://github.com/nm47/dotfiles.git ~/.config/ && \
    /opt/nvim-linux64/bin/nvim --headless "+Lazy! sync" +qa && \
    /opt/nvim-linux64/bin/nvim --headless "+MasonUpdate" +qa && \
    mkdir dev_ws

WORKDIR /home/$USERNAME/dev_ws/
CMD ["bash"]
