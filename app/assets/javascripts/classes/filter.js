import qs from "query-string";
import uniq from "lodash.uniq";

export default class Filter {
  constructor() {
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

    this.applyQueryFilters();

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

  applyQueryFilters() {
    const { filter } = qs.parse(window.location.search, {
      arrayFormat: "comma",
    });

    if (filter) {
      if (Array.isArray(filter)) {
        this.applyFilters(filter);
      } else if (typeof filter === "string") {
        this.applyFilters([filter]);
      }
    }
  }

  applyFilters(values) {
    this.unSelectFilterByActions();

    values
      .filter((v) => !!v)
      .forEach((value) => {
        let actions = this.filterActions.filter((el) => {
          return (
            el.getAttribute("data-filter-by-many") === value ||
            el.getAttribute("data-filter-by") === value
          );
        });

        if (actions.length) {
          actions.forEach((a) => this.toggleAction(a));
        }
      });

    this.filter();
  }

  setFilterQueryParams(filter) {
    const string = qs.stringify(
      { filter: uniq(filter) },
      { arrayFormat: "comma" }
    );

    const url = window.location.pathname + "?" + string;
    history.pushState({}, "", url);
  }

  setCounters() {
    this.filterActions.forEach((element) => {
      if (element.getAttribute("data-filter-by")) return;

      const filterOn = element.getAttribute("data-filter-by-many");
      const count = this.filterableElements.filter(
        (e) =>
          !e.node.classList.contains("hidden") &&
          (e.filterOn.includes(filterOn) || filterOn === "default")
      ).length;

      const toUpdate = element.querySelector(".component__filter-count");
      if (toUpdate) toUpdate.innerHTML = count;
    });
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
    ) {
      this.setCounters();
      return;
    }

    const toHide = this.filterableElements.filter((element) => {
      return !masterFilterList.every((s) => element.filterOn.includes(s));
    });

    this.hideElements(toHide.map((el) => el.node));
    this.setFilterQueryParams(masterFilterList);

    this.setCounters();

    if (!document.querySelector("[data-filter-by].selected")) {
      const els = this.filterActions.filter(
        (f) => f.getAttribute("data-filter-by") === "default"
      );

      els.forEach((el) => this.toggleAction(el));
    }
  }
}
