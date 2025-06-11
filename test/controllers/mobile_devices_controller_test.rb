require "test_helper"

class MobileDevicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mobile_access = MobileAccess.create!(app_name: "mobile_app", server_token: "valid_token")
    @valid_token = @mobile_access.server_token
    @mobile_user = MobileUser.create!(external_key: "user_external_key", mobile_access: @mobile_access)
    @mobile_device = MobileDevice.create!(device_token: "12345", mobile_user: @mobile_user)
  end

  def authenticated_request(method, path, params: {})
    send(method, path, params: params, headers: { "Authorization" => "Bearer #{@valid_token}" })
  end

  test "should create mobile device and user" do
    assert_difference("MobileDevice.count") do
      authenticated_request(:post, mobile_devices_url, params: {
        mobile_device: {
          device_token: "67890",
          user_info: "New User Info",
          device_info: "New Device Info"
        },
        mobile_user: {
          external_key: "new_user_external_key"
        }
      })
    end
    assert_response :success
  end

  test "should return existing mobile device and user" do
    authenticated_request(:post, mobile_devices_url, params: {
      mobile_device: {
        device_token: "12345"
      }
    })
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "12345", json_response["mobile_device"]["device_token"]
    assert_equal @mobile_user.external_key, json_response["mobile_user"]["external_key"]
  end

  test "should not create mobile device with invalid params" do
    assert_no_difference("MobileDevice.count") do
      authenticated_request(:post, mobile_devices_url, params: {
        mobile_device: {
          device_token: nil
        },
        mobile_user: {
          external_key: "user_external_key"
        }
      })
    end
    assert_response :bad_request
    json_response = JSON.parse(response.body)

    assert_includes json_response["errors"], "Device token can't be blank"
  end

  test "should destroy mobile device" do
    assert_difference("MobileDevice.count", -1) do
      authenticated_request(:delete, mobile_device_url(@mobile_device.device_token))
    end
    assert_response :success
  end
end
