import Search from "./classes/search.js";
import Filter from "./classes/filter.js";
import Tooltip from "./classes/tooltip.js";
import Carousel from "./classes/carousel.js";
import LazyLoader from "./classes/lazyLoader.js";
import MobileRelocater from "./classes/mobileRelocater.js";

document.addEventListener("DOMContentLoaded", () => {
  //new Search('[data-role="search"]');
  // document.querySelectorAll("[tooltip]").forEach((element) => {
  //   new Tooltip({
  //     target: element,
  //     html: element.getAttribute("tooltip"),
  //   });
  // });
  // document.querySelectorAll("[data-toggle-target]").forEach((element) => {
  //   element.addEventListener("click", () => {
  //     const query = element.getAttribute("data-toggle-target");
  //     document
  //       .querySelectorAll(query)
  //       .forEach((c) => c.classList.toggle("hidden"));
  //     element.classList.toggle("active");
  //   });
  // });
  // const searchInput = document.querySelector(".global-header__search-input");
  // const header = document.querySelector(".global-header");
  // searchInput.addEventListener("focus", () => {
  //   header.classList.add("global-header--search-focus");
  //   searchInput.addEventListener("blur", () => {
  //     header.classList.remove("global-header--search-focus");
  //   });
  // });
  // if (document.querySelector("[data-filterable-table]")) {
  //   const filter = new Filter();
  //   document.querySelectorAll("[data-table-link]").forEach((element) => {
  //     const params = [element.getAttribute("data-table-link")];
  //     element.addEventListener("click", () => {
  //       const url = window.location.pathname + `?filter=${params}`;
  //       history.pushState({}, "", url);
  //       filter.applyQueryFilters();
  //     });
  //   });
  // }
  // const instagram_count = document.querySelector("[data-instagram-count]");
  // if (instagram_count) {
  //   const count = fetch("https://www.instagram.com/tuxedono2/?__a=1")
  //     .then((blob) => blob.json())
  //     .then((json) => {
  //       try {
  //         const {
  //           graphql: {
  //             user: {
  //               edge_followed_by: { count },
  //             },
  //           },
  //         } = json;
  //         instagram_count.innerHTML = `${count.toLocaleString(
  //           "en-US"
  //         )} followers`;
  //       } catch (error) {
  //         console.error(
  //           `couldn't fetch instagram data. errored out with: ${JSON.stringify(
  //             error.message
  //           )}`
  //         );
  //       }
  //     });
  // }
  // const imagesForCarousel = document.querySelectorAll("[data-carousel-index]");
  // if (imagesForCarousel.length) new Carousel([...imagesForCarousel]);
  // const toMoveOnMobile = document.querySelectorAll("[data-relocate-to]");
  // [...toMoveOnMobile].forEach((toMove) => new MobileRelocater(toMove));
  // const lookForLazyLoaders = () => {
  //   const lazyScroll = document.querySelector("[data-lazy-load-on-scroll]");
  //   const lazyClick = document.querySelector("[data-lazy-load-on-click]");
  //   if (lazyScroll) new LazyLoader(lazyScroll, "onScroll", lookForLazyLoaders);
  //   if (lazyClick)
  //     new LazyLoader(lazyClick, "onClick", () => {
  //       lazyClick.remove();
  //       lookForLazyLoaders();
  //     });
  // };
  // lookForLazyLoaders();
  // const editButton = document.querySelector("[data-edit-link]");
  // const adminButton = document.querySelector("[data-admin-link]");
  // if (editButton && adminButton)
  //   adminButton.insertAdjacentElement("afterend", editButton);
  // if (document.querySelector(".list")) {
  //   document
  //     .querySelector(".global-header")
  //     .classList.add("global-header--list");
  // }
  document.body.classList.add("js-ready");
});
