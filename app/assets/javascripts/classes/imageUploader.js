import aws from 'aws-sdk';
aws.config.region = 'us-east-2';

export default class ImageUploader {
  constructor({key, secret}) {
    this.bucket = new AWS.S3({
      accessKeyId: key,
      secretAccessKey: secret, 
      params: { Bucket: 'chrissy-tuxedo-no2' }
    });
  }

  uploadImage(file) {
    return new Promise((resolve, reject) => {
      this.bucket.putObject({
        Key: file.name,
        ContentType: file.type,
        Body: file,
        ACL: 'public-read'
      }, (err, data) => {
        if (err) console.log(err)
        resolve(file.name)
      });
    });
  }

  upload(file, cb) {
    return new Promise((resolve) => {
      this.uploadImage(file).then(() => {
        resolve(file);
      });
    })
  }
}
