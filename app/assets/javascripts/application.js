import $ from 'jquery';
import Search from './classes/search.js';
import Image from './classes/image.js';

$(() => {
  const search = new Search('[data-role="search"]');

  $("[data-lazy-load]").each(function () {
    let img = new Image($(this));
    img.upscale();
  });

  $("div[href]").on("click", function () {
    window.location = $(this).attr("href");
  });

  const toggleSocialPrompt = () => $(".social-prompt").toggleClass("active");
  window.setTimeout(toggleSocialPrompt, 1000);
  window.setTimeout(toggleSocialPrompt, 4000);
});
