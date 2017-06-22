const path = require('path')
const CopyWebpackPlugin = require('copy-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin')

module.exports = {
  entry: {
    'act.desktop': './web/static/js/act.desktop.js',
    'act.mobile': './web/static/js/act.desktop.js',
    app: './web/static/js/app.js',
    css: [
      './web/static/css/app.css',
      './web/static/css/bnc.css',
      './web/static/css/jd.css',
      './web/static/css/footer.css',
      './web/static/css/header.css',
      './web/static/css/tab-menu.css'
    ]
  },

  output: {
    path: path.resolve(__dirname, 'priv/static'),
    filename: 'js/[name].js'
  },

  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
        query: {
          presets: ['es2015', 'react'],
          plugins: [
            'transform-class-properties',
            'transform-object-rest-spread',
            [
              'import',
              {
                libraryName: 'antd',
                style: 'css'
              }
            ]
          ]
        }
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract({
          fallback: 'style-loader',
          use: 'css-loader'
        })
      }
    ]
  },

  resolve: {
    alias: {
      phoenix_html:
        __dirname + '/deps/phoenix_html/web/static/js/phoenix_html.js',
      phoenix: __dirname + '/deps/phoenix/web/static/js/phoenix.js',
      react: 'preact-compat',
      'react-dom': 'preact-compat'
    }
  },

  plugins: [
    new ExtractTextPlugin('css/app.css'),
    new CopyWebpackPlugin([{ from: './web/static/assets' }])
  ]
}
