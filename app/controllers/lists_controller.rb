class ListsController < ApplicationController
  layout "application"

  def show
    @list = List.find(params[:id])
  end

  def home
    @list = List.find_by_name("Home") || List.first || Recipe.last
    render 'show'
  end

  def edit
    @list = List.find(params[:id])
  end

  def new
    @list = List.new
  end

  def update
    list = List.find(params[:id])
    list.update_attributes(list_params)
    list.compile_and_store_list_elements
    redirect_to action: "show", id: list.id
  end

  def create
    list = List.create(list_params)
    list.update_attributes(list_params)
    list.compile_and_store_list_elements
    redirect_to action: "show", id: list.id
  end

  def delete
    @list.delete
    redirect_to "/"
  end

  def all
    @lists = List.all.map(&:name)
    respond_to do |format|
      format.json {}
    end
  end

  def admin
    @recipes = Recipe.all.sort_by(&:name)
    @components = Component.all.sort_by(&:name)
    @lists = List.all.sort_by(&:name)
  end

  private

  def list_params
    params.require(:list).permit(:name, :content_as_markdown)
  end
end