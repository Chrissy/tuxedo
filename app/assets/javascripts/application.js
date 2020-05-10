import Search from "./classes/search.js";
import Filter from "./classes/filter.js";
import Tooltip from "./classes/tooltip.js";
import Carousel from "./classes/carousel.js";

document.addEventListener("DOMContentLoaded", () => {
  new Search('[data-role="search"]');
  new Filter("[data-filterable-table]");

  document.querySelectorAll("[tooltip]").forEach((element) => {
    new Tooltip({
      target: element,
      html: element.getAttribute("tooltip"),
    });
  });

  const imagesForCarousel = document.querySelectorAll("[data-carousel-index]");
  if (imagesForCarousel.length) new Carousel([...imagesForCarousel]);
});
