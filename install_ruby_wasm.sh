
#!/bin/bash
# https://github.com/ruby/ruby.wasm
#curl -LO https://github.com/ruby/ruby.wasm/releases/latest/download/ruby-head-wasm32-unknown-wasi-full.tar.gz
curl -LO https://github.com/ruby/ruby.wasm/releases/download/2022-08-09-a/ruby-head-wasm32-unknown-wasi-full.tar.gz
tar xfz ruby-head-wasm32-unknown-wasi-full.tar.gz
mv head-wasm32-unknown-wasi-full/usr/local/bin/ruby ruby.wasm
mkdir -p bin/
mv ruby.wasm bin/
