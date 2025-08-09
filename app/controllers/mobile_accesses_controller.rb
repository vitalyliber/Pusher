class MobileAccessesController < ApplicationController
  def index
    devices = mobile_access.mobile_devices.includes(:mobile_user)
    devices = devices.search_by_info(params[:query]) if params[:query].present?
    devices = devices.order(updated_at: :desc)

    @pagy, @mobile_devices = pagy(devices)
  end

  def edit
    if mobile_access.fcm_json_key.blank? || mobile_access.fcm_project_id.blank?
      flash[:alert] = "Please configure FCM settings."
    end

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
