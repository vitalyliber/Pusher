class MobileUsersController < ApplicationController
  before_action :set_mobile_user, only: [ :add_topic, :remove_topic ]

  def remove_topic
    if @mobile_user.topics.include?(topic)
      @mobile_user.topics.delete(topic)
      @mobile_user.save
      flash[:notice] = "Topic '#{topic}' removed successfully."
    else
      flash[:alert] = "Topic '#{topic}' not found."
    end
    redirect_to mobile_device_path(@mobile_user.external_key)
  end

  def add_topic
    if topic.present? && !@mobile_user.topics.include?(topic)
      @mobile_user.topics << topic
      @mobile_user.save
      flash[:notice] = "Topic '#{topic}' added successfully."
    else
      flash[:alert] = "Invalid topic or topic already exists."
    end
    redirect_to mobile_device_path(@mobile_user.external_key)
  end

  private

  def topic
    @_topic ||= params[:topic].parameterize(separator: "_")
  end

  def set_mobile_user
    @mobile_user = MobileUser.find_by(id: params[:id])
    unless @mobile_user
      redirect_to mobile_users_path, alert: "Mobile user not found."
    end
  end
end
