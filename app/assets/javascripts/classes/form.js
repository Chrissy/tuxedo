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

  lastIndexOfWhiteSpace(string) {
    var lastIndex = Math.max(string.lastIndexOf(" "), string.lastIndexOf("\n"));
    if (lastIndex === -1) return 0;
    return lastIndex;
  }

  textUntilCursor(input) {
    return input.value.slice(0, input.selectionStart);
  }

  textUntilFlag(input, flag) {
    var untilCursor = this.textUntilCursor(input);
    return untilCursor.slice(0, untilCursor.lastIndexOf(flag));
  }

  textAfterCursor(input) {
    return input.value.slice(input.selectionStart);
  }

  queryText(input) {
    var untilCursor = this.textUntilCursor(input);

    return untilCursor.slice(this.lastIndexOfWhiteSpace(untilCursor)).trim();
  }

  swapWithComponentLink(form, text, flag) {
    var replacementText = `${flag}[${text}]`;
    var newSelectionStart = form.selectionStart + replacementText.length - this.queryText(form).length;

    form.value = this.textUntilFlag(form, flag) + replacementText + this.textAfterCursor(form);
    form.setSelectionRange(newSelectionStart, newSelectionStart)
  }

  setupAutoComplete(data, flag) {
    const form = this.form[0];
    var data = data;
    new Awesomplete(form, {
      list: data,
      minChars: 1,
      autoFirst: true,
      filter: function(text, input) {
        var queryText = this.queryText(this.form[0]);
        return queryText.indexOf(flag) === 0 && RegExp("^" + escapeStringRegexp(queryText.slice(1)), "i").test(text);
      }.bind(this),
      replace: function(text) {
        this.swapWithComponentLink(this.form[0], text.value, flag);
      }.bind(this)
    });
  }
}
