require "test_helper"

class Api::MobileDevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mobile_access = mobile_accesses(:mobile_access)
    @valid_token = @mobile_access.server_token
    @mobile_device = mobile_devices(:mobile_device)
  end

  def authenticated_request(method, path, params: {})
    send(method, path, params: params, headers: { "Authorization" => "Bearer #{@valid_token}" })
  end

  test "should create mobile device" do
    fcm_mock = Minitest::Mock.new

    # Firtst call
    fcm_mock.expect(:batch_topic_subscription, true, [ String, Array ])
    fcm_mock.expect(:create, { body: "{\"notification_key\":\"xxx\"}" }, [ String, nil, Array ])

    # Second call
    fcm_mock.expect(:batch_topic_subscription, true, [ String, Array ])
    fcm_mock.expect(:add, { body: "{}" }, [ String, nil, nil, Array ])

    # Third call
    fcm_mock.expect(:batch_topic_subscription, true, [ String, Array ])
    fcm_mock.expect(:create, { body: "{\"notification_key\":\"xxx\"}" }, [ String, nil, Array ])

    assert_difference({ "MobileDevice.count" => 2, "MobileUser.count" => 2 }) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          mobile_device: {
            device_token: "0001",
            user_info: "New User Info",
            device_info: "New Device Info",
            external_key: "user_external_key"
          }
        })

        authenticated_request(:post, api_mobile_devices_url, params: {
          mobile_device: {
            device_token: "0002",
            user_info: "New User Info",
            device_info: "New Device Info",
            external_key: "user_external_key"
          }
        })

        # Change an external_key for existing mobile device
        authenticated_request(:post, api_mobile_devices_url, params: {
          mobile_device: {
            device_token: "0002",
            user_info: "New User Info",
            device_info: "New Device Info",
            external_key: "new_user_external_key"
          }
        })
      end
    end
    fcm_mock.verify
    assert_response :success
  end

  # @TODO: Add tests for existing mobile device and user
  # Need to ensure that we attach topics and update device tokens in device group for new mobile device for existing mobile user

  test "should return existing mobile device and user" do
    authenticated_request(:post, api_mobile_devices_url, params: {
      mobile_device: {
        device_token: @mobile_device.device_token,
        external_key: @mobile_device.external_key
      }
    })
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "12345", json_response["mobile_device"]["device_token"]
    assert_equal @mobile_device.external_key, json_response["mobile_device"]["external_key"]
  end

  test "should not create mobile device with invalid params" do
    assert_no_difference("MobileDevice.count") do
      authenticated_request(:post, api_mobile_devices_url, params: {
        mobile_device: {
          device_token: nil,
          external_key: "user_external_key"
        }
      })
    end
    assert_response :bad_request
    json_response = JSON.parse(response.body)

    assert_includes json_response["errors"], "Device token can't be blank"
  end

  test "should destroy mobile device" do
    fcm_mock = Minitest::Mock.new

    fcm_mock.expect(:remove, { body: "{}" }, [ String, nil, String, Array ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ String, Array ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ String, Array ])

    assert_difference("MobileDevice.count", -1) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:delete, api_mobile_device_url(@mobile_device.device_token))
      end
    end
    fcm_mock.verify
    assert_response :success
  end
end
