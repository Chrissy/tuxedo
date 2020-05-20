import Search from "./classes/search.js";
import Filter from "./classes/filter.js";
import Tooltip from "./classes/tooltip.js";
import Carousel from "./classes/carousel.js";
import LazyLoader from "./classes/lazyLoader.js";
import MobileRelocater from "./classes/mobileRelocater.js";

document.addEventListener("DOMContentLoaded", () => {
  new Search('[data-role="search"]');
  new Filter("[data-filterable-table]");

  document.querySelectorAll("[tooltip]").forEach((element) => {
    new Tooltip({
      target: element,
      html: element.getAttribute("tooltip"),
    });
  });

  document.querySelectorAll("[data-toggle-target]").forEach((element) => {
    element.addEventListener("click", () => {
      const query = element.getAttribute("data-toggle-target");
      document
        .querySelectorAll(query)
        .forEach((c) => c.classList.toggle("hidden"));
      element.classList.toggle("active");
    });
  });

  const searchInput = document.querySelector(".global-header__search-input");
  const header = document.querySelector(".global-header");

  searchInput.addEventListener("focus", () => {
    header.classList.add("global-header--search-focus");

    searchInput.addEventListener("blur", () => {
      header.classList.remove("global-header--search-focus");
    });
  });

  const imagesForCarousel = document.querySelectorAll("[data-carousel-index]");
  if (imagesForCarousel.length) new Carousel([...imagesForCarousel]);

  const toMoveOnMobile = document.querySelectorAll("[data-relocate-to]");
  [...toMoveOnMobile].forEach((toMove) => new MobileRelocater(toMove));

  const lookForLazyLoaders = () => {
    const lazyScroll = document.querySelector("[data-lazy-load-on-scroll]");
    const lazyClick = document.querySelector("[data-lazy-load-on-click]");

    if (lazyScroll) new LazyLoader(lazyScroll, "onScroll", lookForLazyLoaders);
    if (lazyClick) new LazyLoader(lazyClick, "onClick", lookForLazyLoaders);
  };

  lookForLazyLoaders();
});
