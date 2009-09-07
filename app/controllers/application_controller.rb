# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  helper_method :current_user
  def current_user
    @current_user ||= User.get(session[:user_id])
  end

  helper_method :logged_in?
  def logged_in?
    not current_user.blank?
  end

  def need_login
    if not logged_in?
      flash[:notice] = "You need to be logged in before you can do that. No worries, go ahead and login now. It won't hurt, I promise."
      session[:return_to] = request.request_uri
      redirect_to login_url
      return false
    else
      return true
    end
  end

  def need_admin
    if logged_in? and current_user.type == 'admin'
      return true
    end
    flash[:notice] = "Sorry mate, you need to be an admin to do that"
    redirect_to root_url
    return false
  end
end
