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
    return $.get("/autocomplete.json").then(data => data);
  }

  listenForSelect() {
    /*
    we are using jquery listeners because they bind in order.
    when we switch off awesomeplete, lets stop this
    */

    $(this.input).on("awesomplete-select", function(event) {
      event.preventDefault();
      this.autoCompleteSelected = true;
      window.location = event.originalEvent.text.value;
    }.bind(this));

    $(this.input).on("keydown", function(event) {
      if (event.isComposing) return;
      if (event.keyCode === 13 && !this.autoCompleteSelected) {
        event.preventDefault();
        window.location = `/search?query=${event.originalEvent.target.value}`;
      }
    }.bind(this));
  }
}
