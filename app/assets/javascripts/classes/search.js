import $ from 'jquery';
import Bloodhound from 'bloodhound-js';
import Typeahead from 'typeahead';

export default class Search {
  constructor(input) {
    const self = this;
    this.input = $(input);
    this.get().then((data) => {
      self.build_bloodhound(data);
      self.bloodhound.initialize();
      self.build_typeahead();

      //self.listenForSelect();
    });
  }

  build_bloodhound(data) {
    this.bloodhound = new Bloodhound({
      name: 'recipes',
      local: data,
      datumTokenizer: Bloodhound.tokenizers.whitespace,
      queryTokenizer: Bloodhound.tokenizers.whitespace
    });
  }

  build_typeahead(bloodhound_instance) {
    this.typeahead = Typeahead(this.input[0], {
      source: this.bloodhound.ttAdapter(),
      highlight: false,
      hint: false,
      minLength: 2,
      name: 'recipes',
      displayKey: 'val',
    });
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
