class ComponentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]
  layout "application"

  def show
    @component = Component.friendly.find(params[:id])
    @layout_object = @component
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
    redirect_to action: "show", id: component.id
  end

  def create
    component = Component.create(component_params)
    redirect_to action: "show", id: component.id
  end

  def all
    @components = Component.all.map(&:name)
    respond_to do |format|
      format.json {}
    end
  end

  def delete
    Component.find(params[:id]).delete() if user_signed_in?
    redirect_to action: "admin", controller: "lists"
  end

  private

  def component_params
    params.require(:component).permit(:name, :image, :nick, :pseudonyms_as_markdown, :never_make_me_tall, :list_as_markdown)
  end
end
