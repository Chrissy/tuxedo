class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_sharing_cookie

  def authenticate_before_render
    render inline: user_signed_in?.to_s
  end
  
  def set_sharing_cookie
    cookies[:visit_count] = { value: cookies[:visit_count].to_i + 1, expires: 1.days.from_now }
  end
end
