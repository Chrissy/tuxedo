const path = require('path');
const Dotenv = require('dotenv-webpack');

module.exports = {
  mode: (process.env['NODE_ENV'] || 'development'),
  plugins: [
    new Dotenv({
      S3_KEY: true,
      S3_SECRET: true,
    })
  ],
  entry: {
    application: './app/assets/javascripts/application.js',
    cms: './app/assets/javascripts/cms.js',
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'public/dist'),
  },
};
