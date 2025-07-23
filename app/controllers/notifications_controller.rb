class NotificationsController < ApplicationController
  def index
    @target = params[:target] || "one"
  end

  def create
    @target = params[:target]
    @result = mobile_access.send_notification(
      data: notification_params[:data],
      topic: notification_params[:topic],
      external_key: notification_params[:external_key]
    )
    render :index, status: :unprocessable_entity
  end

  def search_mobile_devices
    query = params[:query]
    if query.present?
      @mobile_devices = mobile_access.mobile_devices.where(external_key: query)
    else
      @mobile_devices = MobileDevice.none
    end
  end

  private

  def notification_params
    params.expect(notification: [ :data, :topic, :external_key ])
  end
end
