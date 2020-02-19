import Search from "./classes/search.js";
import Tooltip from "./classes/tooltip.js";

document.addEventListener("DOMContentLoaded", () => {
  new Search('[data-role="search"]');

  document.querySelectorAll("[tooltip]").forEach(element => {
    new Tooltip({
      target: element,
      html: element.getAttribute("tooltip")
    });
  });
});
