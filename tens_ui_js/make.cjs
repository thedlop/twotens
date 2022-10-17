const res = require('esbuild').buildSync({
  entryPoints: ['src/main.js'],
  bundle: true,
  minify: true,
  format: 'cjs',
  loader: {'.js':'jsx'},
  sourcemap: false,
  outfile: '../public/assets/tens_ui.js',
  // external: []
});
