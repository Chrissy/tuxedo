import Hammer from "hammerjs";

const BREAKPOINT = 900;

export default class MobileRelocater {
  constructor(
    /* the dom node to relocate */
    toRelocate
  ) {
    const originalPreviousNode = {
      type: toRelocate.previousElementSibling ? "sibling" : "parent",
      element: toRelocate.previousElementSibling || toRelocate.parentElement,
    };

    const relocateAfter = toRelocate
      .getAttribute("data-relocate-to")
      .split(",")
      .map((query) => document.querySelector(query))
      .find((el) => el);

    Object.assign(this, {
      toRelocate,
      relocateAfter,
      originalPreviousNode,
      mode: null,
    });

    this.set();
    window.addEventListener("resize", this.set.bind(this));
  }

  set() {
    const mediaQuery = window.matchMedia(`(max-width: ${BREAKPOINT}px)`);
    if (mediaQuery.matches && this.mode !== "mobile") return this.setMobile();
    if (this.mode === "mobile") return this.setDesktop();
  }

  setMobile() {
    this.relocateAfter.after(this.toRelocate);
    this.mode = "mobile";
  }

  setDesktop() {
    this.mode = "desktop";
    const { type, element } = this.originalPreviousNode;
    return type === "sibling"
      ? element.after(this.toRelocate)
      : element.prepend(this.toRelocate);
  }
}
