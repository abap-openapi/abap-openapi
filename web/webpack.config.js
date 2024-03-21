/* eslint-disable @typescript-eslint/no-require-imports */
/* eslint-disable @typescript-eslint/no-var-requires */
const path = require("path");
const webpack = require("webpack");
const HtmlWebPackPlugin = require("html-webpack-plugin");

module.exports = {
  mode: "development",
  devtool: "nosources-source-map",
  entry: {
    app: "./src/index.js",
    "editor.worker": "monaco-editor/esm/vs/editor/editor.worker.js",
    "json.worker": "monaco-editor/esm/vs/language/json/json.worker",
    "ts.worker": "monaco-editor/esm/vs/language/typescript/ts.worker",
  },
  experiments: {
    topLevelAwait: true
  },
  devServer: {
    open: true,
    hot: true,
  },
  resolve: {
    fallback: {
      "./%23ui2%23cl_json.clas.mjs": false,
      "buffer": require.resolve("buffer/"),
      "crypto": false,
      "fs": false,
      "http": false,
      "https": false,
      "tls": false,
      "process": false,
      "net": false,
      "path": require.resolve("path-browserify"),
      "stream": require.resolve("stream-browserify"),
      "string_decoder": require.resolve("string_decoder/"),
      "url": false,
      "util/types": false,
      "util": require.resolve("web-encoding"),
      "zlib": false,
    },
    extensions: [".ts", ".js"]
  },
  output: {
    globalObject: "self",
    filename: "[name].bundle.js",
    path: path.resolve(__dirname, "dist"),
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"],
      },
      {
        test: /\.ttf$/,
        type: "asset/resource",
        generator: {
          filename: "[name][ext]",
        },
      },
    ],
  },
  plugins: [
    new HtmlWebPackPlugin({
      template: "public/index.html",
    }),
    new webpack.ProvidePlugin({
      Buffer: ['buffer', 'Buffer'],
    }),
  ],
};