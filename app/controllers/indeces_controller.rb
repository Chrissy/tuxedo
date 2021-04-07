# frozen_string_literal: true

class IndecesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index letter_index]
  layout 'application'
  PAGINATION_INTERVAL = 47

  def index
    @elements = Recipe.all_for_display.to_a.concat(Component.all_for_display).sort_by(&:name)
  end

  def home
    @layout_object = @list
    @pagination_end = PAGINATION_INTERVAL - 1
    @list_elements = Recipe.all_for_home[0...PAGINATION_INTERVAL]
    render 'home'
  end

  def more
    @page = params[:page].to_i
    @list = Recipe.all_for_home
    @last = @list.first
    @layout_object = @last
    @pagination_start = PAGINATION_INTERVAL * @page + 1
    @pagination_end = @pagination_start + PAGINATION_INTERVAL - 1
    @list_elements = @list[@pagination_start..@pagination_end]
    @last_page = @list_elements.last.number <= 0
    render 'more', layout: false
  end

  def letter_index
    @elements = Recipe.get_by_letter(params[:letter]).to_a.concat(Component.get_by_letter(params[:letter]).to_a)
    render 'index'
  end
end
