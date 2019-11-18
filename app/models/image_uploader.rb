require 'aws-sdk'
require 'json'
require 'mini_magick'

class ImageUploader
  def initialize(image)
    credentials = get_credentials()
    @path = image
    @s3 = Aws::S3::Client.new(region: 'us-east-2', credentials: credentials)
    @newImage = MiniMagick::Image.open(self.class.bucket + image)
  end

  def get_credentials()
    return Aws::Credentials.new(ENV['S3_KEY'], ENV['S3_SECRET'])
  end


  def source_image
    @newImage
  end

  def file_head(key)
    @s3.head_object(bucket: 'chrissy-tuxedo-no2', key: key)
  end

  def self.all_sizes
    {
      "largeCover" => "1500x861",
      "mediumCover" => "500x287",
      "thumb" => "100x100",
      "pinterest" => "476x666",
      "list" => "600x400"
    }
  end

  def self.sizes(size)
    all_sizes[size]
  end

  def self.bucket
    "https://s3.us-east-2.amazonaws.com/chrissy-tuxedo-no2/"
  end

  def upload()
    self.class.all_sizes.values.each do |size|
      putImageWithSize(size)
    end
  end

  def resize_image(size)
    @newImage.combine_options do |i|
      i.resize(size + "^")
      i.gravity("Center")
      i.extent(size)
    end
  end

  def key(size)
    size + @path
  end

  def putImageWithSize(size)
    resized_image = resize_image(size)

    @s3.put_object(bucket: 'chrissy-tuxedo-no2', body: resized_image.to_blob, key: key(size))
  end
end
