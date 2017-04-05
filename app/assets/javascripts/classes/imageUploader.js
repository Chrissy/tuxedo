import aws from 'aws-sdk';
import '../vendor/facebook';
aws.config.region = 'us-east-2';

export default class ImageUploader {
  constructor() {
    this.bucket = new AWS.S3({
      params: { Bucket: 'chrissy-tuxedo-no2' }
    });
  }

  authorizePerson() {
    return new Promise((resolve, reject) => {
      FB.getLoginStatus((response) => {
        if (response.status === 'connected') return resolve(response.authResponse.accessToken);
        FB.login((response) => resolve(response.authResponse.accessToken));
      });
    });
  }

  uploadImage(file, token) {
    return new Promise((resolve, reject) => {
      this.bucket.config.credentials = new AWS.WebIdentityCredentials({
        ProviderId: 'graph.facebook.com',
        RoleArn: 'arn:aws:iam::707718423679:role/TuxImageUploaderRole',
        WebIdentityToken: token
      });

      this.bucket.putObject({
        Key: file.name,
        ContentType: file.type,
        Body: file,
        ACL: 'public-read'
      }, (err, data) => resolve(file.name));
    });
  }

  upload(file, cb) {
    this.authorizePerson().then(token => {
      this.uploadImage(file, token).then(() => cb(file.name));
    });
  }
}
