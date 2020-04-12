import Fuse from "fuse.js";

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
    /* fires when the footer is clicked. used for "see more" pattern */
    onFooterClick,
    /* used for in-text mentions and comma delimited lists */

    delimiter,
    /* show some random results automatically */
    showResultsOnFocus,
    /* result limit */
    limit,
    /* allow submit on tab as well as enter (useful for in-text mentions) */
    allowSubmitOnTab,
  }) {
    Object.assign(this, {
      input,
      options,
      footer,
      onReturnWithNoSelection,
      delimiter,
      limit,
      showResultsOnFocus,
      allowSubmitOnTab,
      onFooterClick,
    });
    this.onSelect = this.handleSelect(onSelect);
    this.resultsContainer = document.createElement("div");
    const wrapper = document.createElement("div");
    wrapper.setAttribute("class", "autocomplete-wrapper");
    this.resultsContainer.setAttribute(
      "class",
      "autocomplete-results-container"
    );
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
      keys: ["label"],
    };

    this.autocomplete = new Fuse(data, options);
  }

  handleSelect = (selectFunc) => (result, target) => {
    selectFunc(result, target);
    this.reset();
  };

  renderLine(result, active, index) {
    return `
    <a 
      data-list-element=${index}
      class="autocomplete-line ${active ? "active" : ""}"
      href="${result.href ? result.href : "#"}"
    >
      ${result.label}
    </a>
  `;
  }

  getFooter = () => `
    <a href="#" data-footer-target style="display: contents;">
      ${this.footer(this.inputValue)}
    </a>
  `;

  render() {
    const r = () =>
      (this.resultsContainer.innerHTML = this.isOpen
        ? `<div class="autocomplete-container">
        ${this.results.reduce((accumulator, currentValue, index) => {
          return (
            accumulator +
            this.renderLine(currentValue, index === this.arrowIndex, index)
          );
        }, "")}
        ${this.footer ? this.getFooter() : ""}
      </div>`
        : "");

    window.requestAnimationFrame(r);
  }

  setArrowIndex(direction) {
    if (!this.results.length) return null;
    if (this.arrowIndex === null) return (this.arrowIndex = 0);
    this.arrowIndex = (this.arrowIndex + direction) % this.results.length;
    if (this.arrowIndex < 0)
      this.arrowIndex = this.results.length + this.arrowIndex;
  }

  getInputValue(rawInput) {
    const { delimiter, input } = this;

    if (delimiter) {
      return this.getQueryText(rawInput, this.input.selectionStart);
    } else {
      return rawInput;
    }
  }

  sliceFromLastTerminatingCharacter(string) {
    /* 
    a terminating character creates context. we use that context to 
    determine is a user wants to begin a search, rather than already
    having completed one. If we simply look for the last index of
    the flag, that might include previous markdown elements. we use
    spaces, newlines, and another delimiter as indicators of context. 
    */

    var lastIndex = Math.max(
      string.lastIndexOf("]"),
      string.lastIndexOf("\n"),
      string.lastIndexOf(this.delimiter)
    );
    if (lastIndex === -1) return string;
    return string.slice(lastIndex).trim();
  }

  getQueryText(text, selectionStart) {
    const untilCursor = text.slice(0, selectionStart);
    const fromTerminatingChar = this.sliceFromLastTerminatingCharacter(
      untilCursor
    );
    const delimiterPosition = fromTerminatingChar.lastIndexOf(this.delimiter);
    if (delimiterPosition === -1) return "";
    return fromTerminatingChar.slice(delimiterPosition + 1);
  }

  getDefaultOptions() {
    return this.options.slice(0, this.limit);
  }

  search(value) {
    const results = this.autocomplete.search(this.inputValue, {
      limit: this.limit || 10,
    });
    this.results =
      this.showResultsOnFocus && !results.length
        ? this.getDefaultOptions()
        : results;
  }

  reset() {
    this.results = [];
    this.arrowIndex = null;
    this.isOpen = false;
    this.render();
  }

  listenForSelect() {
    this.input.addEventListener("input", (event) => {
      if (!this.isOpen) this.isOpen = true;
      const { value } = event.target;
      this.inputValue = this.getInputValue(value);
      this.search(this.inputValue);
      this.render();
    });

    this.input.addEventListener("keydown", (event) => {
      if (!this.isOpen || !this.results || !this.results.length) return;

      if (
        event.key === "Enter" ||
        (this.allowSubmitOnTab && event.key === "Tab")
      ) {
        if ((this.arrowIndex || this.arrowIndex === 0) && this.results) {
          event.preventDefault();
          this.onSelect(this.results[this.arrowIndex]);
        } else if (this.onReturnWithNoSelection) {
          event.preventDefault();
          this.onReturnWithNoSelection(this.inputValue);
        }
      }

      if (event.key === "ArrowUp") {
        event.preventDefault();
        this.setArrowIndex(-1);
        this.render();
      }

      if (event.key === "ArrowDown") {
        event.preventDefault();
        this.setArrowIndex(1);
        this.render();
      }
    });

    if (this.showResultsOnFocus) {
      this.input.addEventListener("focus", (event) => {
        this.results = this.getDefaultOptions();
        this.isOpen = true;
        this.render();
      });
    }

    this.input.addEventListener("blur", (event) => {
      if (!this.isOpen) return;

      if (event.relatedTarget) {
        const isFooter = event.relatedTarget.getAttribute("data-footer-target");

        if (this.onFooterClick && (isFooter || isFooter === "")) {
          event.preventDefault();
          this.onFooterClick(this.inputValue);
          this.reset();
        }
      } else {
        this.reset();
      }
    });
  }
}
