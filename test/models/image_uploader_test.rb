require 'minitest/autorun'
require 'test_helper.rb'
require 'image_uploader'
require 'recipe.rb'
 
class ImageUploaderTest < Minitest::Test
  def setup
    @uploader = ImageUploader.new("1500x861soul-clench-2b.jpg")
  end

  def test_initializes
    assert @uploader.source_image.width == 1500
  end

  def test_resizes_images
    size = ImageUploader.sizes("mediumCover")
    assert @uploader.resize_image(size).width == 500
  end

  def test_credentials_set
    assert @uploader.get_credentials.set?
  end

  def test_correct_key
    size = ImageUploader.sizes("mediumCover")
    assert @uploader.key(size) == "500x2871500x861soul-clench-2b.jpg"
  end

  def test_connects_to_s3
    assert @uploader.file_head("1500x861soul-clench-2b.jpg").content_length == 93962
  end
end
