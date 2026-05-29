#!/bin/bash
# devcontainer-bootstrap.sh

# Run the actual install script (VSCode fails to parse the --dev flag when using 'dotfiles.installCommand')
./install.sh --dev
