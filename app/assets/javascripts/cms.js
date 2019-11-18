import $ from 'jquery';
import Form from './classes/form.js';
import ImageUploader from './classes/imageUploader';

$(() => {
  const forms = [];

  $('.autocomplete').each(function() {
    let form = new Form(this);
    forms.push(form);
  });

  $(".clear_image").on("click", function() {
    $(this).addClass("cleared").parent().find('#image-filename').attr("value", "");
    return false;
  });

  $(".show-extra-options").on("click", function() {
    $(this).siblings(".extra-options").toggle();
  });

  fetch('/image-upload-token').then(response => response.json()).then((response, reject) => {
    if (reject) console.log("something went wrong", reject);
    const token = response;

    $("#upload-cover-photo").on("change", function(){
      $("input[type='submit']").attr("disabled", true);

      new ImageUploader(token).upload($(this).get(0).files[0], (fileName) => {
        $("input[type='submit']").attr("disabled", false);
        $("#image-filename").val(fileName);
      })
    });
  })

});
