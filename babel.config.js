module.exports = {
  presets: [
    [
      '@babel/preset-env',
      {
        corejs: 3, // core-js版本
        modules: false, // 模块使用 esmodules 语法，不转换
        useBuiltIns: 'usage', // 按需引入 polyfill
      },
    ],
  ],
  plugins: [
    "@babel/plugin-proposal-class-properties", // 支持 class
    [
      '@babel/plugin-transform-runtime', // 抽离babel注入的公共代码
      {
        regenerator: false, // 通过 preset-env 已经使用了全局的 regeneratorRuntime, 不再需要 transform-runtime 提供的 不污染全局的 regeneratorRuntime
        useESModules: true, // 使用 es modules helpers, 不转换 commonJS 语法代码
      },
    ]
  ],
}
