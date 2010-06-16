class LoginController < ApplicationController
  layout 'default'
  before_filter :authorize, :except => [:login, :add_user, :recovery, :resetPassword]
  before_filter :adminonly, :only => [:list_users]

  def index
  end

  # just display the form and wait for user to
  # enter a name and password

  def login
    session[:user_id] = nil
    if request.post?
      if @currentUser = User.authenticate(params[:name], params[:password])
        session[:user_id] = @currentUser.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || { :controller => "main", :action => "personalPage" })
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end
  end

  def add_user
    @user = User.new(params[:user])
    if request.post? and @user.save
      flash.now[:notice] = "User #{@user.username} created"
      @currentUser = @user
      session[:user_id] = @currentUser.id
      @user = User.new
      if defined? uri
        redirect_to(uri || { :controller => "main", :action => "personalPage" })
      else
        redirect_to({ :controller => "main", :action => "personalPage" })
      end
    end
  end

  def delete_user
    if request.post?
      if @currentUser.id == 1
        user = User.find(params[:id])
        begin
          user.safe_delete
          flash[:notice] = "User #{user.username} deleted"
        rescue Exception => e
          flash[:notice] = e.message
        end
      else
        flash[:notice] = "Only the administrator can remove users"
      end
      redirect_to(:action => :list_users)
    end
  end

  def list_users
    @all_users = User.find(:all)
  end

  def logout
    @currentUser = nil
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:controller => "main")
  end

  def resetPassword
    @me = User.find(session[:user_id])
    if request.post?
      unless params[:me][:password].nil?
        unless @me.update_attribute(:password, params[:me][:password])
          errmsg = ""
          @me.errors.each_full { |msg| errmsg = errmsg + msg + ": "}
          flash[:notice] = "Error: #{errmsg}"
        else
          @currentUser = @me
          session[:user_id] = @currentUser.id
          flash[:notice] = "Your password has been changed."
          redirect_to(:controller => "main", :action => "personalPage")
        end
      end
    end
  end

  def recovery
    begin
      key = Crypto.decrypt(params[:key]).split(/:/)
      @currentUser = User.find(key[0], :conditions => {:salt => key[1]})
      session[:user_id] = @currentUser.id
      flash[:notice] = "Please change your password"
      redirect_to(:action => :resetPassword)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "The recovery link given is not valid"
      redirect_to(root_url)
    end
  end
end
