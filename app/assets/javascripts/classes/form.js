import $ from 'jquery';

export default class Form {
  constructor(form) {
    const self = this;
    this.form = $(form);
    this.autocomplete = [];
    if (this.form.hasClass("components")) this.generateAutocomplete("/ingredients/all.json", ":");
    if (this.form.hasClass("recipes")) this.generateAutocomplete("/all.json", "=");
    if (this.form.hasClass("lists")) this.generateAutocomplete("/list/all.json", "#");

    this.form.on("inserted.atwho", (event, flag, query) => {
      var flag = flag.text().trim();
      self.swapWithComponentLink(query, flag);
    });
  }

  getElements(url) {
    $.get(url).then(elements => elements);
  }

  generateAutocomplete(url, flag) {
    const self = this;
    this.getElements(url).promise().then( (data) => {
      self.setupAutoComplete(data, flag);
    });
  }

  setupAutoComplete(data, flag) {
    const self = this;
    this.autocomplete[flag] = this.form.atwho({
      at: flag,
      data: data
    });
  }

  swapWithComponentLink(query, flag) {
    var pretext = this.form.val().substring(0, query.pos);
    var aftertext = this.form.val().substring(query.pos + flag.length + 1);
    var newstr = "#{pretext}[#{flag}]#{aftertext}";
    this.form.val(newstr);
  }
}
