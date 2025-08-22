class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @tweets = @user.tweets.latest
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Profile updated successfully!'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :bio, :email)
  end
end
