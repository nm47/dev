FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

arg USERNAME=niels

# Neovim deps
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-setuptools \
    xclip \
    ninja-build \
    gettext \
    libtool \
    libtool-bin \
    autoconf \
    automake \
    cmake \
    g++ \
    pkg-config \
    unzip \
    curl \
    git \
    doxygen && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip3 install pynvim

# Clone and build Neovim
RUN git clone https://github.com/neovim/neovim.git /neovim && \
    cd /neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make install

# Set Neovim as the default editor
RUN update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60

# install dev env tools
RUN apt-get update && apt-get install -y \
    sudo \
    xclip \
    clangd \
    tree \
    clang-format \
    wget && \
    apt-get clean && \
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
    echo "source ~/.fzf.bash" >> /home/$USERNAME/.bashrc

RUN git clone https://github.com/nm47/dotfiles.git ~/.config/ && \
    nvim --headless "+Lazy! sync" +qa && \
    nvim --headless "+MasonUpdate" +qa && \
    mkdir dev_ws

WORKDIR /home/$USERNAME/dev_ws/
CMD ["bash"]
