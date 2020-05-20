import { debounce } from "throttle-debounce";

const BUFFER = 600;

export default class LazyLoader {
  constructor(element, type, cb) {
    Object.assign(this, {
      element,
      type,
      cb,
      loading: false,
    });

    if (type === "onScroll") {
      window.onscroll = debounce(100, this.checkForLazyLoad.bind(this));
    } else if (type === "onClick") {
      element.addEventListener("click", this.fetchNewContent.bind(this));
    }
  }

  fetchNewContent() {
    if (this.loading) return;

    const url =
      this.element.getAttribute("data-lazy-load-on-scroll") ||
      this.element.getAttribute("data-lazy-load-on-click");
    this.element.classList.add("lazyloader--loading");
    this.loading = true;
    fetch(url)
      .then((res) => res.text())
      .then((text) => {
        this.appendContent(text);
        this.element.classList.remove("lazyloader--loading");
        this.loading = false;
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
    return elemTop - BUFFER < window.innerHeight && elemBottom >= 0;
  }

  checkForLazyLoad() {
    if (this.isScrolledIntoView()) {
      this.fetchNewContent();
    }
  }
}
