const path = require('path');

module.exports = {
  mode: process.env.NODE_ENV || 'development',
  entry: {
    application: './app/assets/javascripts/application.js',
    cms: './app/assets/javascripts/cms.js',
  },
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'public/dist'),
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: ['style-loader', 'css-loader'],
      },
      {
        test: /\.m?js$/,
        exclude: /(node_modules)/,
        use: {loader: 'babel-loader' }
      }
    ],
  },
};
