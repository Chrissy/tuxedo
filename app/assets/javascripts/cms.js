import $ from 'jquery';
import Form from './classes/form.js';
import aws from 'aws-sdk';
aws.config.region = 'us-east-2';

const authorizePerson = () => new Promise((resolve, reject) => {
  FB.getLoginStatus((response) => {
    if (response.status === 'connected') return resolve(response.authResponse.accessToken);
    FB.login((response) => resolve(response.authResponse.accessToken));
  });
});

const uploadImage = (file, token) => new Promise((resolve, reject) => {
  const bucket = new AWS.S3({
    params: {
      Bucket: 'chrissy-tuxedo-no2'
    }
  });

  bucket.config.credentials = new AWS.WebIdentityCredentials({
    ProviderId: 'graph.facebook.com',
    RoleArn: 'arn:aws:iam::707718423679:role/TuxImageUploaderRole',
    WebIdentityToken: token
  });

  bucket.putObject({
    Key: file.name,
    ContentType: file.type,
    Body: file,
    ACL: 'public-read'
  }, (err, data) => resolve(file.name));
});

window.fbAsyncInit = function() {
   FB.init({
     appId: '1514166265511110',
     xfbml: true,
     version: 'v2.8'
   });
 };

 (function(d, s, id){
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) {return;}
    js = d.createElement(s); js.id = id;
    js.src = "//connect.facebook.net/en_US/sdk.js";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));

$(() => {
  const forms = [];

  $('.autocomplete').each(function() {
    let form = new Form(this);
    forms.push(form);
  });

  $("#upload-cover-photo").on("change", function(){
    $("input[type='submit']").attr("disabled", true);

    authorizePerson().then(token => {
      uploadImage($(this).get(0).files[0], token).then(fileName => {
        $("input[type='submit']").attr("disabled", false)
      });
    });
  });

  // $(".clear_image").on("click", function() {
  //   $(this).addClass("cleared").parent().find('[type="filepicker"]').attr("value", "");
  //   return false;
  // });

  $(".show-extra-options").on("click", function() {
    $(this).siblings(".extra-options").toggle();
  });
});
