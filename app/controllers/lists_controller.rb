class ListsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:not_found, :show, :home, :get, :about]
  layout "application"

  def show
    @list ||= List.friendly.find(params[:id])
    @layout_object = @list
  end

  def home
    @list ||= List.find(1)
    @layout_object = @list
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
    redirect_to action: "show", id: list.id
  end

  def create
    list = List.create(list_params)
    list.update_attributes(list_params)
    redirect_to action: "show", id: list.id
  end

  def delete
    List.find(params[:id]).destroy if user_signed_in?
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

  def about
    render 'shared/about'
  end

  def index
    @elements = List.all_for_display
    @type = "Lists"
    render 'shared/index'
  end

  def letter_index
    @elements = List.get_by_letter(params[:letter])
    @type = "Lists"
    render 'shared/letter_index'
  end

  def full_index
    @elements = List.all_for_display.concat(Recipe.all_for_display).concat(Component.all_for_display).sort_by(&:name)
    @type = "Full"
    render 'shared/index'
  end

  private

  def list_params
    params.require(:list).permit(:name, :content_as_markdown, :image, :never_make_me_tall)
  end
end
