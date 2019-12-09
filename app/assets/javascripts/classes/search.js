import $ from 'jquery';
import Fuse from 'fuse.js';

export default class Search {
  constructor(input) {    
    this.input = document.querySelector(input);
    this.resultsContainer = document.createElement("div");
    this.input.parentElement.append(this.resultsContainer);

    const self = this;

    this.get().then((data) => {
      self.build_autocomplete(data);
      self.listenForSelect();
    });
  }

  build_autocomplete(data) {
    var options = {
      shouldSort: true,
      threshold: 0.6,
      location: 0,
      distance: 100,
      maxPatternLength: 32,
      minMatchCharLength: 1,
      keys: [
        "label",
      ]
    };
    this.autocomplete = new Fuse(data, options);
  }

  async get() {
    const response = await fetch("/autocomplete.json");
    const json = await response.json();
    return json;
  }

  renderLine(result) {
    return `<a className="autocomplete-line" href=${result.value}>${result.label}</a>`
  }

  render(results) {
    return (
      `<div className="autocomplete-container">
        ${results.reduce((accumulator, currentValue) => {
          return accumulator + this.renderLine(currentValue);
        }, "")}
      </div>`
    );
  }

  listenForSelect() {
    this.input.addEventListener("input", event => {
      const { value } = event.target;
      const results = this.autocomplete.search(value);
      this.resultsContainer.innerHTML = this.render(results);
    });

    this.input.addEventListener("keydown", event => {
      if (event.key === 'Enter') {
        event.preventDefault();
        window.location = `/search?query=${event.target.value}`;
      }
    })
  }
}
