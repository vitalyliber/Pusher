class NotificationsController < ApplicationController
  def index
  end

  def create
    @result = mobile_access.send_notification(
      data: notification_params[:data],
      topic: notification_params[:topic]
    )
    render "index"
  end

  private

  def notification_params
    params.expect(notification: [ :data, :topic ])
  end
end
