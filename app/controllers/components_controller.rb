class ComponentsController < ActionController::Base
  layout "application"

  def show
    @component = Component.find(params[:id])
  end

  def edit
    @component = Component.find(params[:id])
  end

  def new
  end

  def update
    component = Component.find(params[:id])
    component.update_attributes(component_params)
    redirect_to action: "show", id: component.id
  end

  def create
    component = Component.create(component_params)
    redirect_to action: "show", id: component.id
  end

  def all
    @components = Component.all
    respond_to do |format|
      format.json {}
    end
  end

  private

  def component_params
    params.permit :name, :description, :components
  end
end