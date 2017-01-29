import $ from 'jquery';
import Awesomplete from 'awesomplete';

export default class Search {
  constructor(input) {
    const self = this;
    this.input = document.querySelector(input);
    this.get().then((data) => {
      self.build_autocomplete(data);
      self.listenForSelect();
    });
  }

  build_autocomplete(data) {
    const options = {
      list: data,
      autofirst: true,
      filter: Awesomplete.FILTER_STARTSWITH,
      minChars: 1
    };
    this.autocomplete = new Awesomplete(this.input, options);
  }

  get() {
    return $.get("/search.json").then(data => data);
  }

  listenForSelect() {
    this.input.addEventListener("awesomplete-select", function(event) {
      event.preventDefault();
      window.location = event.text.value;
    });
  }
}
