#---
# Excerpted from "Security on Rails",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/fr_secure for more book information.
#---
class UsersController < ApplicationController

  skip_before_filter :check_authentication, :only => [:index, :new, :create]

  
  def new
    user_type = params[:user].nil? ? '' : params[:user][:type]
    case user_type
    when 'LDAPUser'
      @user = LDAPUser.new(params[:user])
    else
      @user = DbUser.new(params[:user])
    end
  end
  
    
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
    end
  end
  
  
  def create
    # Little glue to create correct account type
    case params[:user][:type]
    when 'LDAPUser'
      @user = LDAPUser.new(params[:user])
    else
      @user = DbUser.new(params[:user])
    end
    
    respond_to do |format|
      if @user.save
        flash[:notice] = 'your account was successfully created.'
        session[:user_id] = @user.id
        format.html { redirect_to(@user) }
      else
        format.html { render :action => 'new' }
      end    
    end
  end
  
end