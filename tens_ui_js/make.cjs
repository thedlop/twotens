const res = require('esbuild').buildSync({
  entryPoints: ['src/main.js'],
  bundle: true,
  // minify: true,
  format: 'cjs',
  loader: {'.js':'jsx'},
  sourcemap: true,
  outfile: '../public/tens_ui.js',
  // external: []
});
