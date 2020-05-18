# frozen_string_literal: true

class IndecesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index letter_index]
  layout 'application'

  def index
    @elements = Recipe.all_for_display.to_a.concat(Component.all_for_display).sort_by(&:name)
  end

  def letter_index
    @elements = Recipe.get_by_letter(params[:letter]).concat(Component.get_by_letter(params[:letter]))
    render 'index'
  end
end
