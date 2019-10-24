require 'aws-sdk'
require 'json'

class ElasticUploader
  def initialize()
    credentials = get_credentials()
    @elastic = Aws::ElasticsearchService::Client.new(region: 'us-east-2', credentials: credentials)
  end

  def get_credentials()
    if ENV['RAILS_ENV'] == 'development'
      creds = JSON.load(File.read('secrets.json'))
      return Aws::Credentials.new(creds['AccessKeyId'], creds['SecretAccessKey'])
    else
      return Aws::Credentials.new(ENV['S3_KEY'], ENV['S3_SECRET'])
    end
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
