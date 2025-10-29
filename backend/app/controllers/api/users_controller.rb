module Api
  class UsersController < BaseController
    before_action :require_current_user!

    def update
      user = current_user
      if user.update(user_params)
        render json: { user: user.to_api }
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      permitted = params.require(:user).permit(:location_permission, :location_latitude, :location_longitude)
      if permitted[:location_permission] == false || permitted[:location_permission] == "false"
        permitted[:location_latitude] = nil
        permitted[:location_longitude] = nil
      end
      permitted
    end
  end
end