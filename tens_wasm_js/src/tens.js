import { WASI, init } from '@wasmer/wasi'
import {WasmFs } from '@wasmer/wasmfs'
import tensWasm from '../tens.wasm'

// source: https://docs.wasmer.io/integrations/js/wasi/browser/examples/hello-world
//const wasmFilePath = './tens.wasm'

// TODO: Move all top level things to this class

// It would be great if we could include the wasm in 
// the js bundle so we don't have require it in the view code

// This will be the interface accessing the tens encoder/decoder
export class TensEncoder {
  initRuntime;
  wasi;
  instance;
  wasmFs;
  compiledWasm;

  constructor(tensInput) {
    this.initRuntime = false;
    this.compiledWasm = undefined;
    this.tensInput = tensInput;
  }

  async wasmInit() {
    await init();
    console.log("compiling")
    //let response  = await fetch(wasmFilePath)
    //let wasmBytes = new Uint8Array(await response.arrayBuffer())
    //this.compiledWasm = await WebAssembly.compile(wasmBytes);
    this.compiledWasm = await WebAssembly.compile(tensWasm);
    this.initRuntime = true;
  }

  async instantiate() { 
    if (!this.initRuntime) {
      await this.wasmInit();
    }
    this.initWASI(this.tensInput);
    const imports = this.wasi.getImports(this.compiledWasm);
    console.log("instantiating")
    this.instance = await WebAssembly.instantiate(this.compiledWasm, imports);
    const exit = this.wasi.start(this.instance);
    if (exit !== 0) {
      throw new Error("tens_encoder: could not initialize encoder");
    }
    console.log(this.instance);
    console.log(this.instance.exports);
    let output = String.fromCharCode(...this.wasi.getStdoutBuffer())
    console.log(output)
    return output
  }

  // TODO
  // Requires repl_entry()
  // async encode(encode_json_str) {
  //   const te = new TextEncoder();
  //   this.wasi.setStdinBuffer(te.encode("`encode_json_str`\n"));
  //   console.log(String.fromCharCode(...this.wasi.getStdoutBuffer()))
  // }

  // async exit() {
  //   const te = new TextEncoder();
  //   this.wasi.setStdinBuffer(te.encode("exit\n"));
  // }

  async initWASI(tensInput) {
    // const tensInput = '{"data":"Dark Lord of Programming","keyorder":"Dark LodfPgmin","options":{"orientation":"center","padding":100},"ir_size":6,"color_profile":"gray"}'
    const args = ["--", "/usr/local/lib/tens/lib/wasm_entry.rb", tensInput];
    //const args = [wasmFilePath, "--", "/usr/local/lib/tens/lib/wasm_entry.rb", tensInput];

    this.wasmFs = new WasmFs();
    console.log("Creating new wasi...");
    this.wasi = new WASI({
      args: args,
      env: {},
      bindings: {
        fs: this.wasmFs
      }
    });
  }
}



//let wasi = new WASI({
//  // Arguments passed to the Wasm Module
//  // The first argument is usually the filepath to the executable WASI module
//  // we want to run.
//  args: [wasmFilePath, tensInput], 
//  // Environment variables that are accesible to the WASI module
//  env: {},
//  // Bindings that are used by the WASI Instance (fs, path, etc...)
//  bindings: {
//    fs: WasmFs.fs
//  }
//})
//
//// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//// Async function to run our WASI module/instance
//const startWasiTask =
//  async pathToWasmFile => {
//    // Fetch our Wasm File
//    let response  = await fetch(pathToWasmFile)
//    let wasmBytes = new Uint8Array(await response.arrayBuffer())
//    // IMPORTANT:
//    // Some WASI module interfaces use datatypes that cannot yet be transferred
//    // between environments (for example, you can't yet send a JavaScript BigInt
//    // to a WebAssembly i64).  Therefore, the interface to such modules has to
//    // be transformed using `@wasmer/wasm-transformer`, which we will cover in
//    // a later example
//    // Instantiate the WebAssembly file
//    let wasmModule = await WebAssembly.compile(wasmBytes);
//    let instance = await WebAssembly.instantiate(wasmModule, {
//    ...wasi.getImports(wasmModule)
//    });
//    wasi.start(instance)                      // Start the WASI instance
//    let stdout = await WasmFs.getStdOut()     // Get the contents of stdout
//    document.write(`Standard Output: ${stdout}`) // Write stdout data to the DOM
//}
//// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//// Everything starts here
//startWasiTask(wasmFilePath)
