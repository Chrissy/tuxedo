class ListsController < ApplicationController
  layout "application"

  def show
    @list = List.find(params[:id])
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
    List.find(params[:id]).delete() if user_signed_in?
    redirect_to "/"
  end

  def all
    @lists = List.all.map(&:name)
    respond_to do |format|
      format.json {}
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :content_as_markdown)
  end
end