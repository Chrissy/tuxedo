import Fuse from 'fuse.js';

export default class Autocomplete {
  constructor({
    /* the input to add the stuff to */
    input,
    /* the list of options, with structure like: { content, href } */
    options,
    /* a footer for full text search, etc */
    footer,
    /* fires when an option is selected */
    onSelect,
    /* fires when the enter key is pressed but nothing is selected */
    onReturnWithNoSelection,
    /* used for mentions and comma delimited lists */
    delimiter,
    /* show some random results automatically */
    showResultsOnFocus,
    /* result limit */
    limit
  }) {    
    Object.assign(this, { input, options, footer, onSelect, onReturnWithNoSelection, delimiter, limit, showResultsOnFocus });
    this.resultsContainer = document.createElement("div");
    const wrapper = document.createElement("div")
    wrapper.setAttribute("class", "autocomplete-wrapper");
    this.resultsContainer.setAttribute("class", "autocomplete-results-container")
    this.input.parentElement.insertBefore(wrapper, this.input);
    wrapper.appendChild(this.resultsContainer);
    wrapper.appendChild(this.input);
    this.arrowIndex = null;
    this.results = [];
    this.isOpen = false;

    this.build_autocomplete(options);
    this.listenForSelect();
  }

  build_autocomplete(data) {
    var options = {
      shouldSort: true,
      threshold: 0.6,
      location: 0,
      distance: 100,
      maxPatternLength: 32,
      minMatchCharLength: 0,
      keys: [
        "label",
      ]
    };

    this.autocomplete = new Fuse(data, options);
  }

  renderLine(result, active, index) {
    return `
    <a 
      data-list-element=${index}
      class="autocomplete-line ${active ? 'active' : ''}"
      href="${result.href ? result.href : '#'}"
    >
      ${result.label}
    </a>
  `
  }

  render() {
    const r = () => this.resultsContainer.innerHTML = this.isOpen ? (
      `<div class="autocomplete-container">
        ${this.results.reduce((accumulator, currentValue, index) => {
          return accumulator + this.renderLine(currentValue, index === this.arrowIndex, index);
        }, "")}
        ${this.footer ? this.footer(this.inputValue) : ''}
      </div>`
    ) : '';

    window.requestAnimationFrame(r);
  }

  setArrowIndex(direction) {
    if (!this.results.length) return null;
    if (this.arrowIndex === null) return this.arrowIndex = 0;
    this.arrowIndex = (this.arrowIndex + direction) % this.results.length;
    if (this.arrowIndex < 0) this.arrowIndex = this.results.length + this.arrowIndex;
  }

  getInputValue(rawInput) {
    const { delimiter } = this;

    if (delimiter) {
      return rawInput.slice(rawInput.lastIndexOf(delimiter) + 1).trim();
    } else {
      return rawInput;
    }
  }

  getDefaultOptions() {
    return this.options.slice(0, this.limit);
  }

  search(value) {
    const results = this.autocomplete.search(this.inputValue, {limit: this.limit || 10});
    this.results = (this.showResultsOnFocus && !results.length) ? this.getDefaultOptions() : results;
  }

  listenForSelect() {
    this.input.addEventListener("input", event => {
      if (!this.isOpen) this.isOpen = true;
      const { value } = event.target;
      this.inputValue = this.getInputValue(value);
      this.search(this.inputValue);
      this.render();
    });

    this.input.addEventListener("keydown", event => {
      if (!this.isOpen) return;

      if (event.key === 'Enter') {
        event.preventDefault();
        if (this.arrowIndex && this.results) {
          this.onSelect(this.results[this.arrowIndex]);
        } else if (this.onReturnWithNoSelection) {
          this.onReturnWithNoSelection(this.inputValue);
        }
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

    if (this.showResultsOnFocus) {
      this.input.addEventListener("focus", event => {
        this.results = this.getDefaultOptions()
        this.isOpen = true;
        this.render();
      })
    }

    this.input.addEventListener("blur", event => {
      if (!this.isOpen) return;

      if (event.relatedTarget) {
        const attribute = event.relatedTarget.getAttribute("data-list-element");
        if (attribute || attribute === '') {
          event.preventDefault();
          if (attribute) this.onSelect(this.results[parseInt(attribute)]);
          return
        }
      };

      this.results = [];
      this.arrowIndex = null;
      this.isOpen = false;
      this.render();
    })
  }
}
