# frozen_string_literal: true

class ComponentsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show index letter_index recents]
  layout 'application'

  def show
    @component = Component.friendly.find(params[:id])
    @layout_object = @component
  end

  def recents
    pagination_interval = 6
    @component = Component.find(params[:id])
    @page = params[:page].to_i
    @pagination_start = @page == 1 ? 3 : pagination_interval * @page + 1
    @pagination_end = @pagination_start + pagination_interval - 1
    @last_page = @pagination_end >= @component.all_elements.count
    @latest = @component.latest_recipes(pagination_interval, @pagination_start)
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
    @components = Subcomponent.all.map(&:name).concat(Component.all.map(&:name)).uniq
    respond_to do |format|
      format.json {}
    end
  end

  def delete
    Component.find(params[:id]).destroy if user_signed_in?
    redirect_to action: 'admin', controller: 'lists'
  end

  def index
    @elements = Component.all_for_display.sort_by { |c| c.name.downcase }
  end

  def letter_index
    @elements = Component.get_by_letter(params[:letter]).sort_by { |c| c.name.downcase }
  end

  private

  def component_params
    params.require(:component).permit(
      :name,
      :image,
      :nick,
      :pseudonyms_as_markdown,
      :never_make_me_tall,
      :skip_subcomponent_search,
      :list_as_markdown,
      :tags_as_text,
      :description,
      :tag_list,
      :subtitle,
      :substitutes_as_markdown
    )
  end
end
