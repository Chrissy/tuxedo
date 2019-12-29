import "regenerator-runtime/runtime";
import Autocomplete from "./autocomplete";

export default class Search {
  constructor(input) {    
    this.get("/autocomplete.json").then((data) => {
      this.autocomplete = new Autocomplete({
        input: document.querySelector(input),
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

  getFullTextSearchUrl(inputValue) {
    return `/search?query=${inputValue}`;
  }

  onReturnWithNoSelection = (inputValue) => {
    window.location = this.getFullTextSearchUrl(inputValue);
  }

  onSelect(option) {
    window.location = option.href;
  }

  getFooter = (inputValue) => {
    return `
      <a
      data-list-element
      class="autocomplete-line full-text-search" 
      href="${this.getFullTextSearchUrl(inputValue)}"
    >
      See More Results »
    </a>`
  }
}
