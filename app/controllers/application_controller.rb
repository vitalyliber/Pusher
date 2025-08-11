class ApplicationController < ActionController::Base
  before_action :restrict_access
  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def restrict_access
    if mobile_access.blank?
      # If the session token is present but no MobileAccess is found, clear the session token
      session.delete(:token)
      unless request.path == root_path
        redirect_to root_path, alert: "Access token is invalid or expired. Please log in again."
      end
    end
  end

  def mobile_access
    return @_mobile_access if defined?(@_mobile_access)

    @_mobile_access = MobileAccess.find_by(server_token: session[:token]) if session[:token].present?
  end

  helper_method :mobile_access
end
