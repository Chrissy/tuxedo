# frozen_string_literal: true

module Tooltip
  include Image

  def self.tooltip(element)
    t = Tooltip.new
    t.tooltip(element)
  end

  def tooltip(element)
    "<div class='tooltip'>
      #{ingredient_card_image(element, 'tooltip__image')}
      <div class='tooltip__title'>#{element.name}</div>
      #{if element.try(:subtitle).present?
          "<div class='tooltip__description'>#{element.subtitle}</div>"
        end}
      <svg class='tooltip__tip'><use href='dist/sprite.svg#tooltip-tip-white'></use></svg>
    </div>"
  end

  def text_tooltip(text)
    "<div class='tooltip tooltip--text'>
      <div class='tooltip__title tooltip__title--center'>#{text}</div>
      <svg class='tooltip__tip'><use href='dist/sprite.svg#tooltip-tip-white'></use></svg>
    </div>"
  end
end
