export default class Tooltip {
  constructor({
    /* the table to apply filtering to */
    parentNode,
  }) {
    Object.assign(this, {
      parentNode,
    });

    this.filterableElements = [
      ...document.querySelectorAll("[data-ingredients]"),
    ].map((el) => {
      return {
        node: el,
        filterOn: el.getAttribute("data-ingredients").split(","),
      };
    });

    this.filterActions = [
      ...document.querySelectorAll("[data-filter-by], [data-filter-by-many]"),
    ];

    this.filterActions.forEach((action) => {
      action.addEventListener("click", (event) => {
        event.preventDefault();
        if (action.hasAttribute("data-filter-by")) {
          this.unSelectFilterByActions();
          this.toggleAction(action);
        } else if (action.hasAttribute("data-filter-by-many")) {
          this.toggleAction(action);
        }
        this.filter();
      });
    });
  }

  toggleAction(element) {
    element.classList.toggle("selected");
  }

  showAllElements() {
    this.filterableElements
      .map((e) => e.node)
      .forEach((element) => {
        return element.classList.remove("hidden");
      });
  }

  hideElements(elements) {
    elements.forEach((element) => element.classList.add("hidden"));
  }

  unSelectFilterByActions() {
    this.filterActions
      .filter((el) => el.hasAttribute("data-filter-by"))
      .forEach((e) => e.classList.remove("selected"));
  }

  getFilterOptions(el) {
    const list =
      el.getAttribute("data-filter-by-many") ||
      el.getAttribute("data-filter-by");
    return list.split(",");
  }

  filter() {
    const masterFilterList = this.filterActions
      .filter((el) => {
        return (
          el.classList.contains("selected") &&
          el.getAttribute("data-filter-by") !== "default"
        );
      })
      .reduce((a, r) => [...a, ...this.getFilterOptions(r)], []);

    this.showAllElements();

    if (
      !masterFilterList.length ||
      (!masterFilterList.length === 1 && masterFilterList.includes("default"))
    )
      return;

    const toHide = this.filterableElements.filter((element) => {
      return !masterFilterList.every((s) => element.filterOn.includes(s));
    });

    this.hideElements(toHide.map((el) => el.node));
  }
}
