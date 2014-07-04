class ComponentsController < ApplicationController
  layout "application"

  def show
    @component = Component.find(params[:id])
    #@image = @component.image ? @component.image : @recipes.first.image
  end

  def edit
    @component = Component.find(params[:id])
  end

  def new
  end

  def update
    component = Component.find(params[:id])
    component.update_attributes(component_params)
    component.create_or_update_list(params[:component][:list_as_markdown])
    redirect_to action: "show", id: component.id
  end

  def create
    component = Component.create(component_params)
    component.create_list(params[:component][:list_as_markdown])
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
    params.require(:component).permit(:name, :description, :image)
  end
end