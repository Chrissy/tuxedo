import Autocomplete from "./autocomplete";

const tags = [
  "classic",
  "original",
  "stirred",
  "shaken",
  "built in glass",
  "up",
  "rocks",
  "large cube",
  "crushed ice",
  "cracked ice",
  "served hot",
  "cocktail glass",
  "collins glass",
  "rocks glass",
  "tiki glass",
  "toddy glass",
  "summer",
  "winter",
  "fall",
  "spring",
];

export default class TagSelect {
  constructor(input) {
    this.input = input;
    this.autocomplete = new Autocomplete({
      input: this.input,
      options: tags.map((option) => ({ label: option })),
      onSelect: this.onSelect,
      delimiter: ",",
      showResultsOnFocus: true,
      allowSubmitOnTab: true,
      keepOpenUntilBlur: true,
      limit: 100,
    });
  }

  getFullTextSearchUrl(inputValue) {
    return `/search?query=${inputValue}`;
  }

  onSelect = (result) => {
    const { value } = this.input;
    const lastDelimiterIndex = value.lastIndexOf(",");
    const beforeText =
      lastDelimiterIndex !== -1 ? value.slice(0, lastDelimiterIndex + 2) : "";
    this.input.value = beforeText + `${result.label}, `;
  };

  onReturnWithNoSelection = (inputValue) => {
    window.location = this.getFullTextSearchUrl(inputValue);
  };
}
