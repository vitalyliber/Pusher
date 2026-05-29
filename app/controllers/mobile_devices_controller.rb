class MobileDevicesController < ApplicationController
  def show
    @mobile_user = MobileUser.find_by(external_key: params[:id])
    @mobile_devices = mobile_access.mobile_devices.where(external_key: params[:id]).order(updated_at: :desc)
  end

  def new
    @mobile_device = MobileDevice.new
  end

  def create
    permitted_params = params.require(:mobile_device).permit(:device_token, :user_info, :device_info, :external_key, :push_provider)

    if permitted_params[:push_provider] == "huawei"
      service = HuaweiMobileDeviceService.new(
        permitted_params[:device_token],
        permitted_params[:user_info],
        permitted_params[:device_info],
        permitted_params[:external_key],
        mobile_access
      )
    else
      service = FirebaseMobileDeviceService.new(
        permitted_params[:device_token],
        permitted_params[:user_info],
        permitted_params[:device_info],
        permitted_params[:external_key],
        mobile_access
      )
    end
    @result = service.create
    @mobile_device = MobileDevice.new

    if @result.dig(:json, :status) == 200
      flash[:notice] = @result.dig(:json, :messages)&.join(", ") || "Mobile device created successfully."

      return redirect_to root_path if permitted_params[:external_key].blank?

      redirect_to mobile_device_path(permitted_params[:external_key])
    else
      flash[:alert] = @result.dig(:json, :errors)&.join(", ")
      redirect_to new_mobile_device_path
    end
  end

  def stats
    @daily_firebase_count = mobile_device_count(:firebase, :daily)
    @daily_huawei_count = mobile_device_count(:huawei, :daily)

    @weekly_firebase_count = mobile_device_count(:firebase, :weekly)
    @weekly_huawei_count = mobile_device_count(:huawei, :weekly)

    @monthly_firebase_count = mobile_device_count(:firebase, :monthly)
    @monthly_huawei_count = mobile_device_count(:huawei, :monthly)
  end

  def mobile_device_count(platform, timeframe)
    cache_key = "mobile_device_#{mobile_access.id}_#{platform}_stats_#{timeframe}"
    timeframe_duration = case timeframe
    when :daily then 1.day
    when :weekly then 1.week
    when :monthly then 1.month
    else raise ArgumentError, "Invalid timeframe: #{timeframe}"
    end

    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      query = mobile_access.mobile_devices
      query = query.send(platform) if platform.present?
      query.where("updated_at >= ?", timeframe_duration.ago).distinct.count
    end
  end
end
