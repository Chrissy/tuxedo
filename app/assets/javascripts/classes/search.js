import $ from 'jquery';
import Fuse from 'fuse.js';
import { throws } from 'assert';

export default class Search {
  constructor(input) {    
    this.input = document.querySelector(input);
    this.resultsContainer = document.createElement("div");
    this.input.parentElement.append(this.resultsContainer);
    this.arrowIndex = null;
    this.results = [];

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

  renderLine(result, active) {
    return `<a class="autocomplete-line ${active && 'active'}" href=${result.value}>${result.label}</a>`
  }

  render() {
    return this.resultsContainer.innerHTML = (
      `<div class="autocomplete-container">
        ${this.results.reduce((accumulator, currentValue, index) => {
          return accumulator + this.renderLine(currentValue, index === this.arrowIndex);
        }, "")}
      </div>`
    );
  }

  setArrowIndex(direction) {
    if (!this.results.length) return null;
    if (this.arrowIndex === null) return this.arrowIndex = 0;
    this.arrowIndex = (this.arrowIndex + direction) % this.results.length;
    if (this.arrowIndex < 0) this.arrowIndex = this.results.length + this.arrowIndex;
  }

  listenForSelect() {
    this.input.addEventListener("input", event => {
      const { value } = event.target;
      this.results = this.autocomplete.search(value);
      this.render();
    });

    this.input.addEventListener("keydown", event => {
      if (event.key === 'Enter') {
        event.preventDefault();
        if (this.arrowIndex && this.results) {
          return window.location = this.results[this.arrowIndex].value;
        }
        return window.location = `/search?query=${event.target.value}`;
      }

      if (event.key === 'ArrowUp') {
        this.setArrowIndex(-1);
        this.render();
      }

      if (event.key === 'ArrowDown') {
        this.setArrowIndex(1);
        this.render();
      }
    });

    this.input.addEventListener("blur", event => {
      this.results = [];
      this.arrowIndex = null;
      this.render();
    })
  }
}
