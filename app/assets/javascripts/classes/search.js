import "regenerator-runtime/runtime";
import Autocomplete from "./autocomplete";

export default class Search {
  constructor(input) {   
    this.input = document.querySelector(input);

    this.get("/autocomplete.json").then((data) => {
      this.autocomplete = new Autocomplete({
        input: this.input,
        options: data.map(option => ({...option, href: option.value})),
        footer: this.getFooter,
        onSelect: this.onSelect,
        onReturnWithNoSelection: this.onReturnWithNoSelection,
        limit: 6
      })
    });
  }

  async get(url) {
    const response = await fetch(url);
    const json = await response.json();
    return json;
  }

  getFullTextSearchUrl() {
    return `/search?query=${this.input.value}`;
  }

  onReturnWithNoSelection = () => {
    window.location = this.getFullTextSearchUrl();
  }

  onSelect(option, target) {
    window.location = option.href;
  }

  getFooter = () => {
    return `
      <a
      data-list-element
      class="autocomplete-line full-text-search" 
      href="${this.getFullTextSearchUrl()}"
    >
      See More Results »
    </a>`
  }
}
