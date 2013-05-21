# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# DEFINE a global variable called @currentUser that will hold the current user
# object.  If its empty, then there is no user!

class ApplicationController < ActionController::Base

  def forem_user
    @currentUser
  end
  helper_method :forem_user

  helper :all # include all helpers, all the time


  before_filter :log_session_id

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'a09942e565fcaea0c33f8bba97e1903b'

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
    #logger.info "Session ID: " + request.session_options[:id]
    unless session[:user_id].nil?
       @currentUser = User.find_by_id(session[:user_id])
    end
  end

  def adminonly
    unless @currentUser && @currentUser.id == 1
      flash[:notice] = "That page was for admin access only"
      redirect_to(:controller => "main")
      return false;
    end
  end

#  module SavageBeast::AuthenticationSystem
#    protected
#    def update_last_seen_at
#      #return unless logged_in?
#      #User.update_all ['last_seen_at = ?', Time.now.utc], ['id = ?', current_user.id] 
#      #current_user.last_seen_at = Time.now.utc
#    end
#    
#  def login_required
#     unless @currentUser
#        redirect_to(:controller => "login", :action => "login")
#	return false
#     end
#  end
#    
#  def authorized?() 
#	true 
#        redirect_to(:controller => "login", :action => "login")
#  end
#
#  def current_user
#      #logger.info "Returning Current User #{@currentUser}"
#      @currentUser
#  end
#    
#  def logged_in?
#     current_user ? true : false #current_user != 0
#  end
#    
#  def admin?
#     logged_in? && current_user.admin?
#  end
# end
end
