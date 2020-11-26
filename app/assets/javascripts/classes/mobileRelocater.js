import queryString from "query-string";

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

    const relocateBefore = toRelocate
      .getAttribute("data-relocate-to")
      .split(",")
      .map((query) => document.querySelector(query))
      .find((el) => el);

    Object.assign(this, {
      toRelocate,
      relocateBefore,
      originalPreviousNode,
      mode: null,
    });

    this.set();
    window.addEventListener("resize", this.set.bind(this));
  }

  set() {
    const mediaQuery = window.matchMedia(`(max-width: ${BREAKPOINT}px)`);
    const qs = queryString.parse(window.location.search);
    const isMobile = mediaQuery.matches && !qs.desktop;
    if (isMobile && this.mode !== "mobile") return this.setMobile();
    if (!isMobile && this.mode === "mobile") return this.setDesktop();
  }

  setMobile() {
    this.relocateBefore.parentNode.insertBefore(
      this.toRelocate,
      this.relocateBefore
    );
    this.mode = "mobile";
  }

  setDesktop() {
    this.mode = "desktop";
    const { type, element } = this.originalPreviousNode;
    return type === "sibling"
      ? element.parentNode.insertBefore(this.toRelocate, element)
      : element.prepend(this.toRelocate);
  }
}
