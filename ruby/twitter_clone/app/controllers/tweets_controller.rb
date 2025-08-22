class TweetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet, only: [ :destroy ]

  def index
    @tweets = Tweet.includes(:user).latest
    @suggested_users = User.where.not(id: current_user.id).limit(10)
    @tweet = Tweet.new
  end

  def create
    @tweet = current_user.tweets.build(tweet_params)

    if @tweet.save
      redirect_to tweets_path, notice: "Tweet posted successfully!"
    else
      @tweets = Tweet.includes(:user).latest
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    if @tweet.user == current_user
      @tweet.destroy
      redirect_to tweets_path, notice: "Tweet deleted successfully!"
    else
      redirect_to tweets_path, alert: "You can only delete your own tweets!"
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:content)
  end

  def set_tweet
    @tweet = Tweet.find(params[:id])
  end
end
