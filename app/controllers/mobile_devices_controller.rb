class MobileDevicesController < ApplicationController
  def show
    @mobile_user = MobileUser.find_by(external_key: params[:id])
    @mobile_devices = mobile_access.mobile_devices.where(external_key: params[:id]).order(updated_at: :desc)
  end

  def new
    @mobile_device = MobileDevice.new
  end

  def create
    permitted_params = params.require(:mobile_device).permit(:device_token, :user_info, :device_info, :external_key)

    service = MobileDeviceService.new(
      permitted_params[:device_token],
      permitted_params[:user_info],
      permitted_params[:device_info],
      permitted_params[:external_key],
      mobile_access
    )
    @result = service.create
    @mobile_device = MobileDevice.new

    if @result[:status] == 200
      flash[:notice] = @result[:json][:messages]&.join(", ") || "Mobile device created successfully."

      return redirect_to root_path if permitted_params[:external_key].blank?

      redirect_to mobile_device_path(permitted_params[:external_key])
    else
      flash[:alert] = @result[:json][:errors].join(", ")
      redirect_to new_mobile_device_path
    end
  end

  def stats
    @daily_count = Rails.cache.fetch("mobile_device_stats_daily", expires_in: 1.hour) do
      mobile_access.mobile_devices.where("updated_at >= ?", 1.day.ago).distinct.count
    end

    @weekly_count = Rails.cache.fetch("mobile_device_stats_weekly", expires_in: 1.hour) do
      mobile_access.mobile_devices.where("updated_at >= ?", 1.week.ago).distinct.count
    end

    @monthly_count = Rails.cache.fetch("mobile_device_stats_monthly", expires_in: 1.hour) do
      mobile_access.mobile_devices.where("updated_at >= ?", 1.month.ago).distinct.count
    end
  end
end
