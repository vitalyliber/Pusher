class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  skip_before_action :verify_authenticity_token
  before_action :restrict_access

  def restrict_access
    authenticate_or_request_with_http_token do |token, _options|
      token.present? && (@_mobile_access = MobileAccess.find_by(server_token: token))
    end
  end

  def mobile_access
    @_mobile_access
  end
end
