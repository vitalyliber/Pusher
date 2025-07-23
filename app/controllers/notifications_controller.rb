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

  private

  def notification_params
    params.expect(notification: [ :data, :topic, :external_key ])
  end
end
