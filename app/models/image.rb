# frozen_string_literal: true

require 'base64'

module Image
  def image_sizes(size)
    {
      'xxlarge2x' => { width: 1540, height: 1300 },
      'xxlarge' => { width: 770, height: 650 },
      'xlarge2x' => { width: 1200, height: 1200 },
      'xlarge' => { width: 600, height: 600 },
      'large2x' => { width: 1120, height: 820 },
      'large' => { width: 560, height: 410 },
      'medium2x' => { width: 600, height: 400 },
      'medium' => { width: 300, height: 200 },
      'small2x' => { width: 200, height: 200 },
      'small' => { width: 100, height: 100 },
      'pinterest' => { width: 476, height: 666 }
    }[size.to_s]
  end

  def image_resize(size)
    {
      resize: {
        width: size[:width],
        height: size[:height],
        fit: 'cover'
      }
    }
  end

  def image_path(size, image)
    Base64.strict_encode64(
      JSON.generate(
        bucket: 'chrissy-tuxedo-no2',
        key: image,
        edits: image_resize(size)
      )
    )
  end

  def image_url(element, size, method = :image_with_backup)
    size_hash = image_sizes(size)
    'https://d34nm4jmyicdxh.cloudfront.net/' + image_path(size_hash, element.send(method))
  end

  def header_image(element, class_name = '', hero = false, carousel = false)
    options = {
      srcset: [
        image_url(element, hero ? :xxlarge : :xlarge) + ' 1x',
        image_url(element, hero ? :xxlarge2x : :xlarge2x) + ' 2x'
      ].join(', '),
      class: class_name,
      alt: "#{element.name} cocktail photo",
      itemprop: 'image',
      role: 'img',
      "data-pin-media": pinnable_image_url(element),
      "data-pin-url": pin_url(element),
      "data-pin-description": element.name
    }

    options['data-carousel-index'] = 1 if carousel

    ActionController::Base.helpers.image_tag(
      image_url(element, hero ? :xxlarge : :xlarge),
      options
    )
  end

  def list_image(element, class_name = '', method = :image_with_backup, carousel_index = nil)
    options = {
      srcset: [image_url(element, :large, method) + ' 1x', image_url(element, :large2x, method) + ' 2x'].join(', '),
      alt: "#{element.name} cocktail photo",
      itemprop: 'image',
      role: 'img',
      class: class_name || 'list-element__img',
      "data-pin-media": pinnable_image_url(element, method),
      "data-pin-url": pin_url(element),
      "data-pin-description": element.name
    }

    options['data-carousel-index'] = carousel_index if carousel_index

    ActionController::Base.helpers.image_tag(
      image_url(element, :large, method),
      options
    )
  end

  def ingredient_card_image(element, class_name, method = :image_with_backup)
    ActionController::Base.helpers.image_tag(
      image_url(element, :medium, method),
      srcset: [image_url(element, :medium, method) + ' 1x', image_url(element, :medium2x, method) + ' 2x'].join(', '),
      class: class_name,
      alt: "#{element.name} cocktail photo",
      itemprop: 'image',
      role: 'img'
    )
  end

  def index_image(element)
    ActionController::Base.helpers.image_tag(
      image_url(element, :small),
      srcset: [image_url(element, :small) + ' 1x', image_url(element, :small2x) + ' 2x'].join(', '),
      class: 'index-element__img',
      alt: "#{element.name} cocktail photo",
      itemprop: 'image',
      role: 'img'
    )
  end

  def pinnable_image_url(element, method = :image_with_backup)
    image_url(element, :pinterest, method)
  end

  def landscape_social_image_url(element)
    image_url(element, :small)
  end

  def index_header_image
    ActionController::Base.helpers.image_tag 'index-image.png', class: 'header-image', alt: 'cocktail index image'
  end

  def pin_url(element)
    request.protocol + request.host_with_port + element.url
  end
end
