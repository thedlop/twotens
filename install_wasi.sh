#!/bin/bash
# https://github.com/kateinoigakukun/wasi-vfs
export WASI_VFS_VERSION=0.2.0
curl -LO "https://github.com/kateinoigakukun/wasi-vfs/releases/download/v${WASI_VFS_VERSION}/wasi-vfs-cli-x86_64-unknown-linux-gnu.zip"
unzip wasi-vfs-cli-x86_64-unknown-linux-gnu.zip
mv wasi-vfs bin/
