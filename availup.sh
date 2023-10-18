echo "🆙 Starting Availup..."
if [ ! -d "${HOME}/.avail" ]; then
    mkdir ~/.avail
fi
if [ ! -d "${HOME}/.avail-light" ]; then
    mkdir ~/.avail-light
fi
if [ ! -f "${HOME}/.avail/config.yml" ]; then
    touch ~/.avail/config.yml
    echo "log_level = \"info\"\nhttp_server_host = \"0.0.0.0\"\nhttp_server_port = 7001\n\nsecret_key = { seed = \"${RANDOM}avail${RANDOM}\" }\nlibp2p_port = \"37000\"\nfull_node_ws = [\"wss://kate.avail.tools:443/ws\"]\napp_id = 0\nconfidence = 99.0\navail_path = \"${HOME}/.avail-light\"\nbootstraps = [\"/ip4/127.0.0.1/tcp/39000/quic-v1/12D3KooWMm1c4pzeLPGkkCJMAgFbsfQ8xmVDusg272icWsaNHWzN\"]" >~/.avail/config.yml
fi
if [ ! -d "${HOME}/.availup" ]; then
    mkdir ~/.availup
fi
# check if avail-light binary is installed, if yes, just run it
if command -v avail-light >/dev/null 2>&1; then
    echo "✅ Avail is already installed. Starting Avail with default config..."
    avail-light -c ~/.avail/config.yml
fi
ISCURL=command -v curl >/dev/null 2>&1
ISWGET=command -v wget >/dev/null 2>&1
# check if curl or wget is available, if not, throw error
if [ "$ISCURL" = "1" ] && [ "$ISWGET" = "1" ]; then
    echo "🚫 Neither curl nor wget are available. Please install one of these and try again."
    exit 1
fi
# check if environment is amd64 or aarch64, if neither throw error
if [ "$(uname -m)" = "x86_64" ]; then
    # check if curl is available else use wget
    if command -v curl >/dev/null 2>&1; then
        curl -sLO https://github.com/availproject/avail-light/releases/download/v1.7.2/avail-light-linux-amd64.tar.gz
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://github.com/availproject/avail-light/releases/download/v1.7.2/avail-light-linux-amd64.tar.gz
    else
        echo "🚫 Neither curl nor wget are available. Please install one of these and try again."
        exit 1
    fi
    # use tar to extract the downloaded file and move it to /usr/local/bin
    tar -xzf avail-light-linux-amd64.tar.gz
    chmod +x avail-light-linux-amd64
    sudo mv avail-light-linux-amd64 /usr/local/bin/avail-light
    rm avail-light-linux-amd64.tar.gz
elif [ "$(uname -m)" = "arm64" -a "$(uname -s)" = "Darwin" ]; then
    # check if curl is available else use wget
    if command -v curl >/dev/null 2>&1; then
        curl -sLO https://github.com/availproject/avail-light/releases/download/v1.7.2/avail-light-apple-arm64.tar.gz
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://github.com/availproject/avail-light/releases/download/v1.7.2/avail-light-apple-arm64.tar.gz
    else
        echo "🚫 Neither curl nor wget are available. Please install one of these and try again."
        exit 1
    fi
    # use tar to extract the downloaded file and move it to /usr/local/bin
    tar -xzf avail-light-apple-arm64.tar.gz
    chmod +x avail-light-apple-arm64
    sudo mv avail-light-apple-arm64 /usr/local/bin/avail-light
    rm avail-light-apple-arm64.tar.gz
elif [ "$(uname -m)" = "aarch64" -o "$(uname -m)" = "arm64" ]; then
    # check if curl is available else use wget
    if command -v curl >/dev/null 2>&1; then
        curl -sLO https://github.com/availproject/avail-light/releases/download/v1.7.2/avail-light-linux-aarch64.tar.gz
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://github.com/availproject/avail-light/releases/download/v1.7.2/avail-light-linux-aarch64.tar.gz
    else
        echo "🚫 Neither curl nor wget are available. Please install one of these and try again."
        exit 1
    fi
    # use tar to extract the downloaded file and move it to /usr/local/bin
    tar -xzf avail-light-linux-aarch64.tar.gz
    chmod +x avail-light-linux-aarch64
    sudo mv avail-light-linux-aarch64 /usr/local/bin/avail-light
    rm avail-light-linux-aarch64.tar.gz
else
    echo "📥 No binary available for this architecture, building from source instead. This can take a while..."
    # check if cargo is not available, else attempt to install through rustup
    if command -v cargo >/dev/null 2>&1; then
        echo "📦 Cargo is available. Building from source..."
    else
        echo "👀 Cargo is not available. Attempting to install with Rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
        echo "📦 Cargo is now available. Reattempting to build from source..."
    fi
    # check if avail-light folder exists in home directory, if yes, pull latest changes, else clone the repo
    if [ -d "${HOME}/avail-light" ]; then
        echo "📂 Avail-light is already cloned. Pulling latest changes..."
        cd ~/avail-light
        git pull
    else
        echo "📂 Avail-light is not cloned. Cloning..."
        git clone -q --depth=1 --single-branch --branch=main https://github.com/availproject/avail-light.git ~/avail-light
        cd ~/avail-light
    fi
    cargo install --locked --path . --bin avail-light
fi
echo "✅ Availup exited successfully."
echo "⛓️ Starting Avail."
avail-light -c ~/.avail/config.yml
echo "🔄 Avail stopped. Future instances of the light client can be started by invoking avail-light -c ~/.avail/config.yml"
