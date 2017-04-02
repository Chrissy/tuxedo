import $ from 'jquery';
import Form from './classes/form.js';
import aws from 'aws-sdk';

var bucketName = 'chrissy-tuxedo-no2';
aws.config.region = 'us-east-2';

var fbUserId;
var bucket = new AWS.S3({
  params: {
    Bucket: bucketName
  }
});

const uploadImage = function(file) {
  FB.login(function(response){
    bucket.config.credentials = new AWS.WebIdentityCredentials({
      ProviderId: 'graph.facebook.com',
      RoleArn: 'arn:aws:iam::707718423679:role/TuxImageUploaderRole',
      WebIdentityToken: response.authResponse.accessToken
    });

    const params = {
      Key: file.name,
      ContentType: file.type,
      Body: file,
      ACL: 'public-read'
    }

    bucket.putObject(params, function (err, data) {
      console.log(data)
    });
  });
}

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
    const file = $(this).get(0).files[0];
    uploadImage(file);
  })

  // $(".clear_image").on("click", function() {
  //   $(this).addClass("cleared").parent().find('[type="filepicker"]').attr("value", "");
  //   return false;
  // });

  $(".show-extra-options").on("click", function() {
    $(this).siblings(".extra-options").toggle();
  });
});
