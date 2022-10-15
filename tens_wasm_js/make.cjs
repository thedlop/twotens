// source https://github.com/guregu/trealla-js/blob/master/make.cjs
const path = require('path');
const esbuild = require('esbuild');
const plugin = require('node-stdlib-browser/helpers/esbuild/plugin');
const stdLibBrowser = require('node-stdlib-browser');

(async () => {
  await esbuild.build({
      entryPoints: ['src/main.js'],
      bundle: true,
      outfile: '../tens_ui_js/src/tens.js',
      format: 'esm',
      loader: {'.wasm': 'binary'},
      target: ['firefox78', 'safari15'],
      minify: false,
      keepNames: true,
      sourcemap: true,
      inject: [require.resolve('node-stdlib-browser/helpers/esbuild/shim')],
      define: {
        Buffer: 'Buffer'
      },
      plugins: [plugin(stdLibBrowser)]
  });
})();
