require "test_helper"

class Api::NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mobile_access = mobile_accesses(:mobile_access)
    @valid_token = @mobile_access.server_token
  end

  def authenticated_request(method, path, params: {})
    send(method, path, params: params, headers: { "Authorization" => "Bearer #{@valid_token}" })
  end

  def huawei_message
    {
      "validate_only": false,
      message: {
        android: {
          notification: {
            title: "Hello",
            body: "World",
            click_action: {
              "type": 3
            }
          }
        }
      }
    }
  end

  test "[Firebase] should create notification successfully" do
    fcm_mock = Minitest::Mock.new

    # Firtst call
    fcm_mock.expect(:send_v1, true, [ Hash ])

    # Second call
    fcm_mock.expect(:send_v1, true, [ Hash ])

    FCM.stub(:new, fcm_mock) do
      authenticated_request(:post, api_notifications_path, params: {
        firebase_payload: { message: "Test notification" },
        topic: "test_topic"
      })

      authenticated_request(:post, api_notifications_path, params: {
        firebase_payload: { message: "Test notification" },
        external_key: "user123"
      })
    end

    assert_response :ok
    assert_equal true, JSON.parse(response.body)["firebase"]["success"]
  end

  test "[Huawei] should create notification successfully" do
    authenticated_request(:post, api_notifications_path, params: {
      huawei_payload: huawei_message,
      topic: "test_topic"
    })

    assert_response :ok
    assert_equal "Please provide valid Huawei credentials", JSON.parse(response.body)["huawei"]["error"]

    authenticated_request(:post, api_notifications_path, params: {
      huawei_payload: huawei_message,
      external_key: "user123"
    })

    assert_response :ok
    assert_equal "Please provide valid Huawei credentials", JSON.parse(response.body)["huawei"]["error"]
  end

  test "[Firebase] should return error when both topic and external_key are present" do
    authenticated_request(:post, api_notifications_path, params: {
      firebase_payload: { message: "Test notification" },
      topic: "test_topic",
      external_key: "user123"
    })

    assert_response :bad_request
    assert_equal "The notification can be sent only on a topic or an external key, not both.", JSON.parse(response.body)["errors"].first
  end

  test "[Huawei] should return error when both topic and external_key are present" do
    authenticated_request(:post, api_notifications_path, params: {
      huawei_payload: { message: "Test notification" },
      topic: "test_topic",
      external_key: "user123"
    })

    assert_response :bad_request
    assert_equal "The notification can be sent only on a topic or an external key, not both.", JSON.parse(response.body)["errors"].first
  end
end
