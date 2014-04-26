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
    redirect_to action: "show", id: list.id
  end

  def create
    list = List.create(list_params)
    redirect_to action: "show", id: list.id
  end

  def delete
    List.find(params[:id]).delete() if user_signed_in?
    redirect_to "/"
  end

  private

  def list_params
    params.require(:list).permit(:name, :content_as_markdown)
  end
end