import "regenerator-runtime/runtime";
import Autocomplete from "./autocomplete";

export default class Form {
  constructor(form) {
    const self = this;
    this.form = form;
    this.autocompletes = [];
    if (form.classList.contains("components"))
      this.generateAutocomplete("/ingredients/all.json", /(\s|\n)\:/, ":");
    if (form.classList.contains("recipes"))
      this.generateAutocomplete("/all.json", /(\s|\n)\=/, "=");
  }

  async get(url) {
    const response = await fetch(url);
    const json = await response.json();
    return json;
  }

  generateAutocomplete(url, flag, symbol) {
    const self = this;
    this.get(url).then((data) => {
      self.setupAutoComplete(data, flag, symbol);
    });
  }

  textUntilFlag(text, flag) {
    var untilCursor = text.slice(0, this.form.selectionStart);
    return untilCursor.slice(0, untilCursor.lastIndexOf(flag));
  }

  textAfterCursor(value) {
    return value.slice(this.form.selectionStart);
  }

  setupAutoComplete(data, flag, symbol) {
    this.autocompletes.push(
      new Autocomplete({
        input: this.form,
        options: data.map((option) => ({ label: option })),
        onSelect: this.onSelect(symbol),
        delimiter: flag,
        symbol,
        limit: 8,
        allowSubmitOnTab: true,
      })
    );
  }

  onSelect = (symbol) => (result) => {
    const { form } = this;
    const { value } = form;
    const replacementText = `${symbol}[${result.label}]`;
    const textUntilFlag = this.textUntilFlag(value, symbol);
    form.value = textUntilFlag + replacementText + this.textAfterCursor(value);
    var newSelectionStart = textUntilFlag.length + replacementText.length;
    form.setSelectionRange(newSelectionStart, newSelectionStart);
  };
}
