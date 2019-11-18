const path = require('path');
const Dotenv = require('dotenv-webpack');

const path = require('path');

module.exports = {
  entry: {
    application: './app/assets/javascripts/application.js',
    cms: './app/assets/javascripts/cms.js',
  },
  output: {
    filename: '[name].bundle.js',
    path: path.resolve(__dirname, 'public/dist'),
  },
};
