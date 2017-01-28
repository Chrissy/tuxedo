import $ from 'jquery';
import Search from './classes/search.js';
import Image from './classes/image.js';
import Form from './classes/form.js';

$(() => {
  const search = new Search('.search');
  const forms = [];

  $('.autocomplete').each(function() {
    let form = new Form(this);
    window.forms.push(form);
  });

  $("[data-resize]").each(function() {
    let img = new Image($(this));
    img.upscale();
  });

  $("[bubble-on-focus]").not("focused").focus(function() {
    const $target = $(this).closest($(this).attr("bubble-on-focus"));
    $target.addClass("focused");
    $(this).blur(() => $target.removeClass("focused"));
  });

  $(".clear_image").on("click", function() {
    $(this).addClass("cleared").parent().find('[type="filepicker"]').attr("value", "");
    return false;
  });

  $(".show-extra-options").on("click", function() {
    $(this).siblings(".extra-options").toggle();
  });

  $("div[href]").on("click", function() {
    window.location = $(this).attr("href");
  });

  const toggleSocialPrompt = () => $(".social-prompt").toggleClass("active");
  window.setTimeout(toggleSocialPrompt, 1000);
  window.setTimeout(toggleSocialPrompt, 4000);
});
