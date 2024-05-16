import { read } from "./persistent";

export const knownExtensions = read('knownExtensions', [
    '.py',
    '.ipynb',
    '.html',
    '.css',
    '.js',
    '.ts',
    '.tsx',
    '.hbs',
    '.gjs',
    '.gts',
    '.jsx',
    '.rst',
    '.md',
  ]);
  
  export  const filesToSkip = read('filesToSkip', [
      '.eslintrc.js',
      '.gitignore',
      '.glintrc.yml',
      '.template-lintrc.js',
      'readme.md',
      'jest.config.ts',
      'postcss.config.js',
      'yarn.lock',
      // 'tsconfig.json',
   
  ]);
  
  export  const dirsToSkip = read('dirsToSkip', [
    '.github',
    'node_modules',
    'build',
    'dist',
    'out',
    '.storybook',
    '.vscode',
  ]);