import $ from 'jquery';
import TagSelect from './classes/tagSelect.js';
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

  document.querySelectorAll(".tag-select").forEach(element => {
    new TagSelect(element);
  })

  fetch('/image-upload-token').then(response => response.json()).then((response, reject) => {
    if (reject) console.log("something went wrong", reject);
    const uploader = new ImageUploader(response);
    const uploads = [];

    $(".upload-cover-photo").on("change", function(){
      $("input[type='submit']").attr("disabled", true);
      uploads.push(uploader.upload($(this).get(0).files[0]).then((file) => {
        $(this).siblings(".image-filename").val(file.name);
      }));
      Promise.all(uploads).then(() => {
        $("input[type='submit']").attr("disabled", false);
      })
    });
  })

});
