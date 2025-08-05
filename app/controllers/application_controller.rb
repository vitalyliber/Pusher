class ApplicationController < ActionController::Base
  include Pagy::Backend
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def mobile_access
    return @_mobile_access if defined?(@_mobile_access)

    @_mobile_access = MobileAccess.find_by(server_token: session[:token]) if session[:token].present?
  end

  helper_method :mobile_access
end
