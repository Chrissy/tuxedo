import $ from 'jquery';
import Search from './classes/search.js';
import Image from './classes/image.js';

$(() => {
  const search = new Search('.search');

  console.log("loading...")

  $("[data-lazy-load]").each(function() {
    console.log("imges...")
    let img = new Image($(this));
    img.upscale();
  });

  $("[bubble-on-focus]").not("focused").focus(function() {
    const $target = $(this).closest($(this).attr("bubble-on-focus"));
    $target.addClass("focused");
    $(this).blur(() => $target.removeClass("focused"));
  });

  $("div[href]").on("click", function() {
    window.location = $(this).attr("href");
  });

  const toggleSocialPrompt = () => $(".social-prompt").toggleClass("active");
  window.setTimeout(toggleSocialPrompt, 1000);
  window.setTimeout(toggleSocialPrompt, 4000);
});
