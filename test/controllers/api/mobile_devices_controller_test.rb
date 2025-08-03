require "test_helper"

class Api::MobileDevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mobile_access = mobile_accesses(:mobile_access)
    @valid_token = @mobile_access.client_token
    @mobile_device = mobile_devices(:mobile_device)
  end

  def authenticated_request(method, path, params: {})
    send(method, path, params: params, headers: { "Authorization" => "Bearer #{@valid_token}" })
  end

  test "should create mobile device and create a notification key" do
    fcm_mock = Minitest::Mock.new

    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ String ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "general", Array ])
    fcm_mock.expect(:create, { body: "{\"notification_key\":\"xxx\"}" }, [ String, nil, Array ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ "unregistered", [ "0001" ] ])

    assert_difference({ "MobileDevice.count" => 1, "MobileUser.count" => 1 }) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          mobile_device: {
            device_token: "0001",
            user_info: "New User Info",
            device_info: "New Device Info",
            external_key: "user_external_key"
          }
        })

        assert_response :success
      end
    end
    fcm_mock.verify
  end

  test "should create mobile device and add device token to device group" do
    fcm_mock = Minitest::Mock.new
    new_device_token = "0002"

    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ new_device_token ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "general", [ new_device_token ] ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "topic1", [ new_device_token ] ])
    fcm_mock.expect(:add, { body: "{}" }, [ "user123", nil, "device_group_token_one", [ @mobile_device.device_token, new_device_token ] ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ "unregistered", [ "0002" ] ])

    assert_difference({ "MobileDevice.count" => 1, "MobileUser.count" => 0 }) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          mobile_device: {
            device_token: new_device_token,
            user_info: "New User Info",
            device_info: "New Device Info",
            external_key: @mobile_device.external_key
          }
        })

        assert_response :success
      end
    end
    fcm_mock.verify
  end

  # Need to ensure that we attach topics and update device tokens in device group for new mobile device for existing mobile user
  test "change an external_key for existing mobile device" do
    fcm_mock = Minitest::Mock.new

    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ String ])
    fcm_mock.expect(:batch_topic_subscription, true, [ String, Array ])
    fcm_mock.expect(:create, { body: "{\"notification_key\":\"xxx\"}" }, [ String, nil, Array ])

    assert_difference({ "MobileDevice.count" => 0, "MobileUser.count" => 1 }) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          mobile_device: {
            device_token: @mobile_device.device_token,
            user_info: "New User Info",
            device_info: "New Device Info",
            external_key: "user_external_key_changed"
          }
        })

        assert_response :success
      end
    end

    fcm_mock.verify
  end

  test "should return existing mobile device and user" do
    fcm_mock = Minitest::Mock.new
    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ String ])

    FCM.stub(:new, fcm_mock) do
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
