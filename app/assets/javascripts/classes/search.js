import $ from 'jquery';
import Awesomplete from 'awesomplete';

export default class Search {
  constructor(input) {
    const self = this;
    this.input = $(input);
    this.get().then((data) => {
      self.build_autocomplete(data);
      //self.listenForSelect();
    });
  }

  build_autocomplete(data) {
    const options = {
      list: data,
      autofirst: true,
      filter: Awesomplete.FILTER_STARTSWITH,
      minChars: 1
    };
    this.autocomplete = new Awesomplete(this.input[0], options);
  }

  get() {
    return $.get("/search.json").then((data) => {
      return data.map(d => d.val);
    });
  }

  listenForSelect() {
    this.input.on("typeahead:selected", (event, object, name) => {
      window.location = object.url
    });
  }
}
