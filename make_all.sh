#!/bin/bash
sh compile_wasm.sh
echo 'Compiling tens_wasm_js...'
cd tens_wasm_js && node make.cjs && cd ../
echo 'Compiling tens_ui_js...'
cd tens_ui_js && node make.cjs && cd ../
