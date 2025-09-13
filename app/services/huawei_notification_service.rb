require "httparty"

class HuaweiNotificationService
  attr_reader :access_token, :client_id, :client_secret

  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret

    token_response = HTTParty.post(
      "https://oauth-login.cloud.huawei.com/oauth2/v3/token",
      body: {
        grant_type: "client_credentials",
        client_id: @client_id,
        client_secret: @client_secret
      }
    )
    Rails.logger.info token_response.body
    @access_token = JSON.parse(token_response.body)["access_token"]
  end

  # The message object example: { notification: title: "Hello", body: "World", tokens: [ "xyz" ] }
  def send_to_devices(token, payload = {})
    body = {
      **payload,
      message: {
        **payload[:message],
        token:
      }
    }

    HTTParty.post(
      "https://push-api.cloud.huawei.com/v1/#{client_id}/messages:send",
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      body: body.to_json
    )
  end

  def valid?(tokens)
    result = send_to_devices(tokens, { "validate_only": false, message: { data: { test: :validate_token }.to_json } })
    Rails.logger.info result
    # 80300007: All the tokens are invalid
    # 80200003: Access token expired
    !(result["code"] == "80300007" || result["code"] == "80200003")
  end
end
