export default {
  multipass: false,
  js2svg: {
    pretty: true,
    indent: 0,
    finalNewline: true,
  },
  plugins: [
    'removeDoctype',
    'removeXMLProcInst',
    'removeComments',
    'removeMetadata',
    'removeEditorsNSData',
    'removeScripts',
    'cleanupAttrs',
    'removeEmptyAttrs',
    'removeUnusedNS',
  ],
};
