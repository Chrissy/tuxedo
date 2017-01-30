import $ from 'jquery';
import escapeStringRegexp from 'escape-string-regexp';
import Awesomplete from 'awesomplete';

export default class Form {
  constructor(form) {
    const self = this;
    this.form = $(form);
    this.autocomplete = [];
    if (this.form.hasClass("components")) this.generateAutocomplete("/ingredients/all.json", ":");
    if (this.form.hasClass("recipes")) this.generateAutocomplete("/all.json", "=");
    if (this.form.hasClass("lists")) this.generateAutocomplete("/list/all.json", "#");

    // this.form.on("inserted.atwho", (event, flag, query) => {
    //   var flag = flag.text().trim();
    //   self.swapWithComponentLink(query, flag);
    // });
  }

  getElements(url) {
    return $.get(url).then(elements => elements);
  }

  generateAutocomplete(url, flag) {
    const self = this;
    this.getElements(url).promise().then( (data) => {
      self.setupAutoComplete(data, flag);
    });
  }

  textUntilCursor(input) {
    return input.value.slice(0, input.selectionStart);
  }

  lastIndexOfWhiteSpace(string) {
    return Math.max(string.lastIndexOf(" "), string.lastIndexOf("\n"));
  }

  cursorToFirstPriorSpace(input) {
    var untilCursor = this.textUntilCursor(input)
    return untilCursor.slice(this.lastIndexOfWhiteSpace(untilCursor)).trim();
  }

  setupAutoComplete(data, flag) {
    const form = this.form[0];
    var data = data;
    new Awesomplete(form, {
      list: data,
      minChars: 1,
      autoFirst: true,
      filter: function(text, input) {
        var cursorToFirstPriorSpace = this.cursorToFirstPriorSpace(this.form[0]);
        return cursorToFirstPriorSpace.indexOf(":") === 0 &&
          RegExp("^" + escapeStringRegexp(cursorToFirstPriorSpace.slice(1)), "i").test(text);
      }.bind(this),
      replace: function(text) {
        var selectionStart = this.form[0].selectionStart;
        var untilCursor = this.form[0].value.slice(0, selectionStart);
        var initialText = untilCursor.slice(0, untilCursor.lastIndexOf(":"));
        var afterText = this.form[0].value.slice(this.form[0].selectionStart);
        this.form[0].value = initialText + ":[" + text.value + "] " + afterText;
        var newSelectionStart = selectionStart + text.value.length + 3 - untilCursor.slice(this.lastIndexOfWhiteSpace(untilCursor)).trim().length;
        this.form[0].setSelectionRange(newSelectionStart, newSelectionStart)
      }.bind(this)
    });
  }

  swapWithComponentLink(query, flag) {
    var pretext = this.form.val().substring(0, query.pos);
    var aftertext = this.form.val().substring(query.pos + flag.length + 1);
    var newstr = "#{pretext}[#{flag}]#{aftertext}";
    this.form.val(newstr);
  }
}
