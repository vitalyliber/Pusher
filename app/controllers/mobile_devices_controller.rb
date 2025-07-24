class MobileDevicesController < ApplicationController
  def show
    @mobile_user = MobileUser.find_by(external_key: params[:id])
    @mobile_devices = mobile_access.mobile_devices.where(external_key: params[:id])
  end
end
