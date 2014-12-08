class ListsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:not_found, :show, :home, :get]
  layout "application"

  def not_found
    @list = List.find_by_name("Home") || List.first
    render 'shared/not_found', :status => :not_found
  end

  def show
    @list = List.friendly.find(params[:id])
    @layout_object = @list
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
    list.collect_and_save_list_elements
    redirect_to action: "show", id: list.id
  end

  def create
    list = List.create(list_params)
    list.update_attributes(list_params)
    list.collect_and_save_list_elements
    redirect_to action: "show", id: list.id
  end

  def delete
    List.find(params[:id]).delete() if user_signed_in?
    redirect_to "/admin"
  end

  def all
    @lists = List.all_for_display.map(&:name)
    respond_to do |format|
      format.json {}
    end
  end
  
  def get
    @list = List.find(params[:id])
    @count_start = params[:start].to_i + 1
    @count_end = @list.elements.count
    respond_to do |format|
      format.html {render :layout => false}
    end
  end

  def admin
    @recipes = Recipe.all.sort_by(&:name)
    @components = Component.all.sort_by(&:name)
    @lists = List.all_for_display.sort_by(&:name)
  end

  private

  def list_params
    params.require(:list).permit(:name, :content_as_markdown, :image)
  end
end