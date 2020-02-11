# frozen_string_literal: true

require 'aws-sdk'
require 'json'
require 'mini_magick'

class ImageUploader
  def initialize(image)
    credentials = get_credentials
    @path = image
    @s3 = Aws::S3::Client.new(region: 'us-east-2', credentials: credentials)
    @baseImage = MiniMagick::Image.open(self.class.bucket + image)
  end

  def get_credentials
    Aws::Credentials.new(ENV['S3_KEY'], ENV['S3_SECRET'])
  end

  def source_image
    @baseImage
  end

  def file_head(key)
    @s3.head_object(bucket: 'chrissy-tuxedo-no2', key: key)
  end

  def self.all_sizes
    {
      'largeCover' => '1500x861',
      'mediumCover' => '500x287',
      'medium' => '200x200',
      'medium2x' => '400x400',
      'thumb' => '100x100',
      'pinterest' => '476x666',
      'list' => '600x400'
    }
  end

  def self.sizes(size)
    all_sizes[size]
  end

  def self.bucket
    'https://s3.us-east-2.amazonaws.com/chrissy-tuxedo-no2/'
  end

  def upload
    self.class.all_sizes.values.each do |size|
      putImageWithSize(size)
    end
  end

  def resize_image(size)
    MiniMagick::Image.open(@baseImage.tempfile.path).combine_options do |i|
      i.resize(size + '^')
      i.gravity('Center')
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
