import { debounce } from "throttle-debounce";

const BUFFER = 300;

export default class LazyLoader {
  constructor(element, type, cb) {
    Object.assign(this, {
      element,
      type,
      cb,
    });

    window.onscroll = debounce(100, this.checkForLazyLoad.bind(this));
  }

  fetchNewContent() {
    const url =
      this.element.getAttribute("data-lazy-load-on-scroll") ||
      this.element.getAttribute("data-lazy-load-on-click");
    fetch(url)
      .then((res) => res.text())
      .then((text) => {
        this.appendContent(text);
      });
  }

  appendContent(text) {
    this.element.parentElement.insertAdjacentHTML("beforeend", text);
    this.element.removeAttribute("data-lazy-load-on-scroll");
    this.element.removeAttribute("data-lazy-load-on-click");
    this.cb();
  }

  isScrolledIntoView(el) {
    var rect = this.element.getBoundingClientRect();
    var elemTop = rect.top;
    var elemBottom = rect.bottom;
    return elemTop < window.innerHeight && elemBottom >= 0;
  }

  checkForLazyLoad() {
    if (this.isScrolledIntoView()) {
      this.fetchNewContent();
    }
  }
}
