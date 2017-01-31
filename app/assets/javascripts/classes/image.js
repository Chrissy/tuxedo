import $ from 'jquery';

export default class Image {
  constructor($image) {
    this.image = $image;
    this.src = $image.attr("src");
  }

  resize() {
    return this.rez = this.rez || parseFloat(this.image.attr("data-resize"));
  }

  dimension(name) {
    var dimension = this.src.match(new RegExp(`\&${name}\=(.*?)(\&|$)`))[1];
    var self = this;
    return () => parseInt(dimension * self.resize());
  }

  filepicker_url() {
    var url = this.src.match(/\/file\/(.*?)\//)[1];
    var compression = (this.image.attr("data-dont-compress")) ? "100" : "60";
    return `https://www.filepicker.io/api/file/${url}/convert?fit=crop&format=jpg&quality=${compression}&h=${this.dimension("h")()}&w=${this.dimension("w")()}&cache=true`;
  }

  upscale() {
    var self = this;
    var img = self.image.clone().attr("src", this.filepicker_url());
    img.on("load", () => self.image.replaceWith(img));
  }
}
