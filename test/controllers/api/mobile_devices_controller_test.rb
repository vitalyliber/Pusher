require "test_helper"

class Api::MobileDevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mobile_access = mobile_accesses(:mobile_access)
    @valid_token = @mobile_access.client_token
    @mobile_device = mobile_devices(:mobile_device)
    @mobile_device_huawei = mobile_devices(:mobile_device_huawei)
  end

  def authenticated_request(method, path, params: {})
    send(method, path, params: params, headers: { "Authorization" => "Bearer #{@valid_token}" })
  end

  test "[Firebase] should create mobile device and create a notification key" do
    fcm_mock = Minitest::Mock.new

    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ String ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "general", Array ])
    fcm_mock.expect(:create, { body: "{\"notification_key\":\"xxx\"}" }, [ String, nil, Array ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ "unregistered", [ "0001" ] ])

    assert_difference({ "MobileDevice.firebase.count" => 1, "MobileUser.count" => 1 }) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: "0001",
          user_info: "New User Info",
          device_info: "New Device Info",
          external_key: "user_external_key"
        })

        assert_response :success
      end
    end
    fcm_mock.verify
  end

  test "[Huawei] should create mobile device" do
    huawei_notification_service_mock = Minitest::Mock.new

    huawei_notification_service_mock.expect(:valid?, true, [ "Huawei_0001" ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "general", [ "Huawei_0001" ] ])
    huawei_notification_service_mock.expect(:unsubscribe_from_topic, true, [ "unregistered", [ "Huawei_0001" ] ])

    assert_difference({ "MobileDevice.huawei.count" => 1, "MobileUser.count" => 1 }) do
      HuaweiNotificationService.stub(:new, huawei_notification_service_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: "Huawei_0001",
          user_info: "New User Info",
          device_info: "New Device Info",
          external_key: "user_external_key",
          push_provider: "huawei"
        })

        assert_response :success
      end
    end
    huawei_notification_service_mock.verify
  end

  test "[Firebase] should create mobile device and add device token to device group" do
    fcm_mock = Minitest::Mock.new
    new_device_token = "0002"

    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ new_device_token ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "general", [ new_device_token ] ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "topic1", [ new_device_token ] ])
    fcm_mock.expect(:add, { body: "{}" }, [ "user123", nil, "device_group_token_one", [ @mobile_device.device_token, new_device_token ] ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ "unregistered", [ "0002" ] ])

    assert_difference({ "MobileDevice.firebase.count" => 1, "MobileUser.count" => 0 }) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: new_device_token,
          user_info: "New User Info",
          device_info: "New Device Info",
          external_key: @mobile_device.external_key
        })

        assert_response :success
      end
    end
    fcm_mock.verify
  end

  test "[Huawei] should create mobile device and add all existing topics" do
    huawei_notification_service_mock = Minitest::Mock.new
    huawei_notification_service_mock.expect(:valid?, true, [ "0002" ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "general", [ "0002" ] ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "topic1", [ "0002" ] ])
    huawei_notification_service_mock.expect(:unsubscribe_from_topic, true, [ "unregistered", [ "0002" ] ])
    new_device_token = "0002"

    assert_difference({ "MobileDevice.huawei.count" => 1, "MobileUser.count" => 0 }) do
      HuaweiNotificationService.stub(:new, huawei_notification_service_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: new_device_token,
          user_info: "New User Info",
          device_info: "New Device Info",
          external_key: @mobile_device_huawei.external_key,
          push_provider: "huawei"
        })

        assert_response :success
      end
    end
    huawei_notification_service_mock.verify
  end

  # Need to ensure that we attach topics and update device tokens in device group for new mobile device for existing mobile user
  test "[Firebase] change an external_key for existing mobile device" do
    fcm_mock = Minitest::Mock.new

    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ String ])
    fcm_mock.expect(:batch_topic_subscription, true, [ String, Array ])
    fcm_mock.expect(:create, { body: "{\"notification_key\":\"xxx\"}" }, [ String, nil, Array ])

    assert_difference({ "MobileDevice.firebase.count" => 0, "MobileUser.count" => 1 }) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: @mobile_device.device_token,
          user_info: "New User Info",
          device_info: "New Device Info",
          external_key: "user_external_key_changed"
        })

        assert_response :success
      end
    end

    fcm_mock.verify
  end

  test "[Huawei] change an external_key for existing mobile device" do
    huawei_notification_service_mock = Minitest::Mock.new
    huawei_notification_service_mock.expect(:valid?, true, [ "huawei_12345" ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "general", [ "huawei_12345" ] ])

    assert_difference({ "MobileDevice.huawei.count" => 0, "MobileUser.count" => 1 }) do
      HuaweiNotificationService.stub(:new, huawei_notification_service_mock) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: @mobile_device_huawei.device_token,
          user_info: "New User Info",
          device_info: "New Device Info",
          external_key: "user_external_key_changed",
          push_provider: "huawei"
        })

        assert_response :success
      end
    end

    huawei_notification_service_mock.verify
  end

  test "[Firebase] should return existing mobile device and user" do
    fcm_mock = Minitest::Mock.new
    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ String ])

    FCM.stub(:new, fcm_mock) do
      authenticated_request(:post, api_mobile_devices_url, params: {
        device_token: @mobile_device.device_token,
        external_key: @mobile_device.external_key
      })
      assert_response :success
      json_response = JSON.parse(response.body)
      assert_equal "12345", json_response["mobile_device"]["device_token"]
      assert_equal @mobile_device.external_key, json_response["mobile_device"]["external_key"]
    end
  end

  test "[Huawei] should return existing mobile device and user" do
    huawei_notification_service_mock = Minitest::Mock.new
    huawei_notification_service_mock.expect(:valid?, true, [ "huawei_12345" ])

    HuaweiNotificationService.stub(:new, huawei_notification_service_mock) do
      authenticated_request(:post, api_mobile_devices_url, params: {
        device_token: @mobile_device_huawei.device_token,
        external_key: @mobile_device_huawei.external_key,
        push_provider: "huawei"
      })
      assert_response :success
      json_response = JSON.parse(response.body)
      assert_equal "huawei_12345", json_response["mobile_device"]["device_token"]
      assert_equal @mobile_device_huawei.external_key, json_response["mobile_device"]["external_key"]
    end
  end

  test "[Firebase] should not create mobile device with invalid params" do
    assert_no_difference("MobileDevice.firebase.count") do
      authenticated_request(:post, api_mobile_devices_url, params: {
        device_token: nil,
        external_key: "user_external_key"
      })
    end
    assert_response :bad_request
    json_response = JSON.parse(response.body)

    assert_includes json_response["errors"], "Device token can't be blank"
  end

  test "[Huawei] should not create mobile device with invalid params" do
    assert_no_difference("MobileDevice.huawei.count") do
      authenticated_request(:post, api_mobile_devices_url, params: {
        device_token: nil,
        external_key: "user_external_key",
        push_provider: "huawei"
      })
    end
    assert_response :bad_request
    json_response = JSON.parse(response.body)

    assert_includes json_response["errors"], "Device token can't be blank"
  end

  test "[Firebase] should add the unregistered topic and remove the mobile device if it exists" do
    fcm_mock = Minitest::Mock.new
    fcm_mock.expect(:get_instance_id_info, { status_code: 200 }, [ String ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "unregistered", [ @mobile_device.device_token ] ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "general", [ @mobile_device.device_token ] ])

    FCM.stub(:new, fcm_mock) do
      assert_difference({ "MobileDevice.firebase.count" => -1, "MobileUser.count" => 0 }) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: @mobile_device.device_token,
          external_key: nil
        })
      end
      assert_response :success
    end
  end

  test "[Huawei] should add the unregistered topic and remove the mobile device if it exists" do
    huawei_notification_service_mock = Minitest::Mock.new
    huawei_notification_service_mock.expect(:valid?, true, [ "huawei_12345" ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "unregistered", [ "huawei_12345" ] ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "general", [ "huawei_12345" ] ])

    HuaweiNotificationService.stub(:new, huawei_notification_service_mock) do
      assert_difference({ "MobileDevice.huawei.count" => -1, "MobileUser.count" => 0 }) do
        authenticated_request(:post, api_mobile_devices_url, params: {
          device_token: @mobile_device_huawei.device_token,
          external_key: nil,
          push_provider: "huawei"
        })
      end
      assert_response :success
    end
  end

  test "[Firebase] should destroy mobile device" do
    fcm_mock = Minitest::Mock.new

    fcm_mock.expect(:remove, { body: "{}" }, [ @mobile_device.external_key, nil, @mobile_device.mobile_user.device_group_token, [ @mobile_device.device_token ] ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ "general", [ @mobile_device.device_token ] ])
    fcm_mock.expect(:batch_topic_unsubscription, true, [ "topic1", [ @mobile_device.device_token ] ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "unregistered", [ @mobile_device.device_token ] ])
    fcm_mock.expect(:batch_topic_subscription, true, [ "general", [ @mobile_device.device_token ] ])

    assert_difference("MobileDevice.count", -1) do
      FCM.stub(:new, fcm_mock) do
        authenticated_request(:delete, api_mobile_device_url(@mobile_device.device_token))
      end
    end
    fcm_mock.verify
    assert_response :success
  end

  test "[Huawei] should destroy mobile device" do
    huawei_notification_service_mock = Minitest::Mock.new

    huawei_notification_service_mock.expect(:unsubscribe_from_topic, true, [ "general", [ "huawei_12345" ] ])
    huawei_notification_service_mock.expect(:unsubscribe_from_topic, true, [ "topic1", [ "huawei_12345" ] ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "unregistered", [ "huawei_12345" ] ])
    huawei_notification_service_mock.expect(:subscribe_to_topic, true, [ "general", [ "huawei_12345" ] ])

    assert_difference("MobileDevice.count", -1) do
      HuaweiNotificationService.stub(:new, huawei_notification_service_mock) do
        authenticated_request(:delete, api_mobile_device_url(@mobile_device_huawei.device_token))
      end
    end
    huawei_notification_service_mock.verify
    assert_response :success
  end
end
