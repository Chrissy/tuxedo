class IndecesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :letter_index]
  layout "application"

  def index
    @elements = List.all_for_display.concat(Recipe.all_for_display).concat(Component.all_for_display).sort_by(&:name)
  end

  def letter_index
    @elements = List.get_by_letter(params[:letter]).concat(Recipe.get_by_letter(params[:letter])).concat(Component.get_by_letter(params[:letter]))
    render 'index'
  end
end
