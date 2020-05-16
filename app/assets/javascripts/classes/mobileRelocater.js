import Hammer from "hammerjs";

const BREAKPOINT = 900;

export default class MobileRelocater {
  constructor(
    /* the dom node to relocate */
    toRelocate
  ) {
    const originalPreviousNode =
      toRelocate.previousElementSibling || toRelocate.parentElement;

    const relocateAfter = toRelocate
      .getAttribute("data-relocate-to")
      .split(",")
      .map((query) => document.querySelector(query))
      .find((el) => el);

    Object.assign(this, {
      toRelocate,
      relocateAfter,
      originalPreviousNode,
    });

    const mediaQuery = window.matchMedia(`(max-width: ${BREAKPOINT}px)`);
    if (mediaQuery.matches) this.setMobile();
  }

  setMobile() {
    this.relocateAfter.after(this.toRelocate);
  }

  setDesktop() {
    this.originalPreviousNode.after(this.toRelocate);
  }
}
