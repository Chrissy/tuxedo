import $ from 'jquery';
import Form from './classes/form.js';
import ImageUploader from './classes/imageUploader';

$(() => {
  const forms = [];

  $('.autocomplete').each(function() {
    let form = new Form(this);
    forms.push(form);
  });

  $("#upload-cover-photo").on("change", function(){
    $("input[type='submit']").attr("disabled", true);

    new ImageUploader().upload($(this).get(0).files[0], (fileName) => {
      $("input[type='submit']").attr("disabled", false);
      $("#image-filename").val(fileName);
    })
  });

  // $(".clear_image").on("click", function() {
  //   $(this).addClass("cleared").parent().find('[type="filepicker"]').attr("value", "");
  //   return false;
  // });

  $(".show-extra-options").on("click", function() {
    $(this).siblings(".extra-options").toggle();
  });
});
