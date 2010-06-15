# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# DEFINE a global variable called @currentUser that will hold the current user
# object.  If its empty, then there is no user!

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :log_session_id

  # avoid writing certain fields into the log
  filter_parameter_logging :contents, :password

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a09942e565fcaea0c33f8bba97e1903b'
  
  private

  def authorize
    unless @currentUser 
      session[:original_uri] = request.request_uri 
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "login")
      return false;
    end
  end

  def log_session_id
    # This is needed because of lazy sessions in the new rails.  non-authorized
    # pages loose the session cookie!
    session[:session_id]
    logger.info "Session ID: " + request.session_options[:id]
    unless session[:user_id].nil?
       @currentUser = User.find_by_id(session[:user_id])
    end
  end

end
