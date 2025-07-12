class SessionsController < ApplicationController
  def create
    if MobileAccess.find_by(server_token: params[:server_token])
      session[:token] = params[:server_token]
      redirect_to root_path, notice: "You have been logged in."
    end
  end

  def destroy
    session[:token] = nil
    redirect_to root_path, notice: "You have been logged out."
  end
end
