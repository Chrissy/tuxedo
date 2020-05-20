# frozen_string_literal: true

PAGINATION_INTERVAL = 6

class ComponentsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show index letter_index]
  layout 'application'

  def show
    @component = Component.friendly.find(params[:id])
    @layout_object = @component
  end

  def recents
    @component = Component.find(params[:id])
    @page = params[:page].to_i
    @pagination_start = PAGINATION_INTERVAL * @page + 1
    @pagination_end = @pagination_start + PAGINATION_INTERVAL - 1
    @last_page = @pagination_end >= @component.all_elements.count
    @latest = @component.latest_recipes(PAGINATION_INTERVAL, @pagination_start)
    render 'recents', layout: false
  end

  def edit
    @component = Component.find(params[:id])
  end

  def new
    @component = Component.new
  end

  def update
    component = Component.find(params[:id])
    component.update_attributes(component_params)
    Relationship.touch_all_parents_of(component)
    redirect_to action: 'show', id: component.id
  end

  def create
    component = Component.create(component_params)
    redirect_to action: 'show', id: component.id
  end

  def all
    @components = Component.all.map(&:name).concat(Subcomponent.all.map(&:name))
    respond_to do |format|
      format.json {}
    end
  end

  def delete
    Component.find(params[:id]).destroy if user_signed_in?
    redirect_to action: 'admin', controller: 'lists'
  end

  def index
    @elements = Component.all_for_display
  end

  def letter_index
    @elements = Component.get_by_letter(params[:letter])
  end

  private

  def component_params
    params.require(:component).permit(
      :name,
      :image,
      :nick,
      :pseudonyms_as_markdown,
      :never_make_me_tall,
      :list_as_markdown,
      :tags_as_text,
      :description,
      :tag_list,
      :subtitle,
      :substitutes_as_markdown
    )
  end
end
