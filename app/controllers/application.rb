# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # avoid writing certain fields into the log
  filter_parameter_logging :contents, :password

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a09942e565fcaea0c33f8bba97e1903b'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  session :session_key => 'book_project_session_id'

  private

  def authorize
    unless User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri 
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login", :action => "login")
      return false;
    end
  end

end
