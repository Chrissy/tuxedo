import "regenerator-runtime/runtime";
import Autocomplete from './autocomplete';

export default class Form {
  constructor(form) {
    const self = this;
    this.form = form;
    this.autocomplete = [];
    if (form.classList.contains("components")) this.generateAutocomplete("/ingredients/all.json", ":");
    if (form.classList.contains("recipes")) this.generateAutocomplete("/all.json", "=");
    if (form.classList.contains("lists")) this.generateAutocomplete("/list/all.json", "#");
  }

  async get(url) {
    const response = await fetch(url);
    const json = await response.json();
    return json;
  }

  generateAutocomplete(url, flag) {
    const self = this;
    this.get(url).then((data) => {
      self.setupAutoComplete(data, flag);
    });
  }

  textUntilFlag(text, flag) {
    var untilCursor = text.slice(0, this.form.selectionStart);
    return untilCursor.slice(0, untilCursor.lastIndexOf(flag));
  }

  textAfterCursor(value) {
    return value.slice(this.form.selectionStart);
  }

  setupAutoComplete(data, flag) {
    this.autocomplete = new Autocomplete({
      input: this.form,
      options: data.map(option => ({ label: option })),
      onSelect: this.onSelect(flag),
      delimiter: flag,
      limit: 8,
      allowSubmitOnTab: true
    });
  }

  onSelect = (flag) => (result) => {
    const {form} = this;
    const {value} = form;
    const replacementText = `${flag}[${result.label}]`;
    const textUntilFlag = this.textUntilFlag(value, flag)
    form.value = textUntilFlag + replacementText + this.textAfterCursor(value);
    var newSelectionStart = textUntilFlag.length + replacementText.length;
    form.setSelectionRange(newSelectionStart, newSelectionStart)
  }
}
