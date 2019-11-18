class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_sharing_cookie
  helper_method :windows?
  
  def windows?
    request.user_agent =~ /.*Windows/
  end

  def token
    render json: {
      :key => ENV["S3_KEY"],
      :secret => ENV["S3_SECRET"]
    } if user_signed_in?
  end
  
  def set_sharing_cookie
    current_count = cookies[:visit_count].to_i
    if current_count < 5
      new_count = current_count + 1
      cookies[:visit_count] = { value: new_count, expires: 3.days.from_now }
    end
  end
end
