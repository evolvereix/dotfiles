module.exports = {
  printWidth: 100, // 一行的字符数，如果超过会进行换行，默认为80
  tabWidth: 2, // 一个tab代表几个空格数，默认为80
  useTabs: false, // 是否使用tab进行缩进，默认为false，表示用空格进行缩进
  semi: false, // 在语句末尾是否使用分号，默认为true，使用分号
  singleQuote: true, // 是否使用单引号，默认为false，使用双引号
  quoteProps: 'as-needed',
  jsxSingleQuote: false,
  trailingComma: 'es5',
  bracketSpacing: true,
  jsxBracketSameLine: false,
  arrowParens: 'always', // 是否在单个箭头函数参数周围加上括号，avoid 尽可能省略parens；always always
  proseWrap: 'preserve',
  htmlWhitespaceSensitivity: 'css',
  endOfLine: 'lf'
}