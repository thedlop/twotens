#!/bin/bash
bundle config set --local path 'vendor/bundle'
bundle install
rm -rf ./head-wasm32-unknown-wasi-full/usr/local/lib/tens
mkdir -p ./head-wasm32-unknown-wasi-full/usr/local/lib/tens
cp Gemfile ./head-wasm32-unknown-wasi-full/usr/local/lib/tens
cp Gemfile.lock ./head-wasm32-unknown-wasi-full/usr/local/lib/tens
cp -r .bundle ./head-wasm32-unknown-wasi-full/usr/local/lib/tens
cp -r vendor/ ./head-wasm32-unknown-wasi-full/usr/local/lib/tens
cp -r lib ./head-wasm32-unknown-wasi-full/usr/local/lib/tens
bin/wasi-vfs pack bin/ruby.wasm \
  --mapdir /usr::./head-wasm32-unknown-wasi-full/usr \
  -o public/tens.wasm
