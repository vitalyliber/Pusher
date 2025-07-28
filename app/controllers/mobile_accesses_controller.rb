class MobileAccessesController < ApplicationController
  def index
    if mobile_access.fcm_json_key.blank? || mobile_access.fcm_project_id.blank?
      redirect_to edit_mobile_access_path(mobile_access), alert: "Please configure FCM settings."
    else
      redirect_to edit_mobile_access_path(mobile_access)
    end
  end

  def edit
    @mobile_access = mobile_access
  end

  def update
    @mobile_access = mobile_access
    if @mobile_access.update(mobile_access_params)
      redirect_to @mobile_access, notice: "FCM settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def mobile_access_params
    params.require(:mobile_access).permit(:fcm_project_id, :fcm_json_key)
  end
end
