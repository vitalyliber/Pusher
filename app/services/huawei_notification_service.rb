require "httparty"

class HuaweiNotificationService
  def initialize(client_id, client_secret)
    @client_id = client_id
    @client_secret = client_secret
  end

  def send_to_devices(device_tokens, title, message)
    token_response = HTTParty.post(
      "https://oauth-login.cloud.huawei.com/oauth2/v3/token",
      body: {
        grant_type: "client_credentials",
        client_id: @client_id,
        client_secret: @client_secret
      }
    )
    access_token = JSON.parse(token_response.body)["access_token"]

    HTTParty.post(
      "https://push-api.cloud.huawei.com/v1/#{@client_id}/messages:send",
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      body: {
        message: {
          notification: {
            title: title,
            body: message
          },
          tokens: device_tokens
        }
      }.to_json
    )
  end
end
