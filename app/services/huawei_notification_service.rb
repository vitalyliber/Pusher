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

  # Send a notification to either devices (tokens) or a topic
  def send_message(payload: {}, tokens: nil, topic: nil)
    raise ArgumentError, "Either tokens or topic must be provided" unless tokens || topic

    body = {
      **payload,
      message: {
        **payload[:message]
      }
    }

    body[:message][:token] = tokens if tokens.present?
    body[:message][:topic] = topic if topic.present?

    response = HTTParty.post(
      "https://push-api.cloud.huawei.com/v1/#{client_id}/messages:send",
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      body: body.to_json
    )

    Rails.logger.info response.body
    JSON.parse(response.body)
  end

  def valid?(token)
    result = send_message(tokens: [ token ], payload: { "validate_only": false, message: { data: { test: :validate_token }.to_json } })
    Rails.logger.info result
    # 80300007: All the tokens are invalid
    # 80200003: Access token expired
    result["code"] == "80000000"
  end

  def test_token_message(token)
    result = send_message(tokens: [ token ], payload: { "validate_only": false,  message: { android: { notification: { title: "Hello", body: "World", click_action: { "type": 3 } } } } })
    Rails.logger.info result
    result["code"] == "80000000"
  end

  def test_topic_message(topic)
    result = send_message(topic:, payload: { "validate_only": false,  message: { android: { notification: { title: "Hello", body: "World", click_action: { "type": 3 } } } } })
    Rails.logger.info result
    result["code"] == "80000000"
  end

  # Subscribe tokens to a topic
  def subscribe_to_topic(topic, tokenArray)
    body = {
      topic:,
      tokenArray:
    }

    response = HTTParty.post(
      "https://push-api.cloud.huawei.com/v1/#{client_id}/topic:subscribe",
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      body: body.to_json
    )

    Rails.logger.info response.body
    JSON.parse(response.body)
  end

  # Unsubscribe tokens from a topic
  def unsubscribe_from_topic(topic, tokenArray)
    body = {
      topic:,
      tokenArray:
    }

    response = HTTParty.post(
      "https://push-api.cloud.huawei.com/v1/#{client_id}/topic:unsubscribe",
      headers: {
        "Authorization" => "Bearer #{access_token}",
        "Content-Type" => "application/json"
      },
      body: body.to_json
    )

    Rails.logger.info response.body
    JSON.parse(response.body)
  end
end
