class MobileDevicesController < ApplicationController
  def show
    @mobile_user = MobileUser.find_by(external_key: params[:id])
    @mobile_devices = mobile_access.mobile_devices.where(external_key: params[:id])
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
