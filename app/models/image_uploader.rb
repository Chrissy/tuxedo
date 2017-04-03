require 'aws-sdk'
require 'json'
require 'mini_magick'

class ImageUploader
  def initialize(image)
    creds = JSON.load(File.read('secrets.json'))
    @sizes = JSON.load(File.read('images.json'))
    credentials = Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])
    @path = image
    @s3 = Aws::S3::Client.new(region: 'us-east-2', credentials: credentials)
    @newImage = MiniMagick::Image.open("https://s3.us-east-2.amazonaws.com/chrissy-tuxedo-no2/" + image)
  end

  def upload()
    @sizes.values.each do |size|
      putImageWithSize(MiniMagick::Image.open(@newImage.path), size)
    end
  end

  def putImageWithSize(image, size)
    image.combine_options do |i|
      i.resize(size + "^")
      i.gravity("Center")
      i.extent(size)
    end

    @s3.put_object(bucket: 'chrissy-tuxedo-no2', body: image.to_blob, key: size + @path)
  end
end
