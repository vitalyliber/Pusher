class ApplicationController < ActionController::Base
  include ActionController::HttpAuthentication::Token
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def mobile_access
    return @_mobile_access if defined?(@_mobile_access)

    token, _options = token_and_options(request)
    @_mobile_access = MobileAccess.find_by(server_token: token)
  end

  helper_method :mobile_access
end
