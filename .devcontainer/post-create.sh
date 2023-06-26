#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "post-create start"
echo "$(date)    post-create start" >> "$HOME/status"

# update the repos
#git -C /workspaces/imdb-app pull
#git -C /workspaces/webvalidate pull
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
echo "Installed SDK MAN"

sdk install java 17.0.7-zulu

echo "Installed Java 17.0.7-zulu"

curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

echo"Installed Tilt"

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"

# Check: https://github.com/bufbuild/buf/releases for latest version
BIN="/usr/local/bin" && \
VERSION="1.22.0" && \
sudo curl -sSL \
"https://github.com/bufbuild/buf/releases/download/v${VERSION}/buf-$(uname -s)-$(uname -m)" \
-o "${BIN}/buf" && \
sudo chmod +x "${BIN}/buf"