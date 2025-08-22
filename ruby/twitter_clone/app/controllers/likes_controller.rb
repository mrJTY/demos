class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_tweet

  def create
    @like = @tweet.likes.build(user: current_user)

    if @like.save
      respond_to do |format|
        format.html { redirect_to tweets_path, notice: 'Tweet liked!' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "like_button_#{@tweet.id}",
            partial: 'tweets/like_button',
            locals: { tweet: @tweet, current_user: current_user }
          )
        }
      end
    else
      redirect_to tweets_path, alert: 'Unable to like tweet.'
    end
  end

  def destroy
    @like = @tweet.likes.find_by(user: current_user)

    if @like&.destroy
      respond_to do |format|
        format.html { redirect_to tweets_path, notice: 'Tweet unliked!' }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "like_button_#{@tweet.id}",
            partial: 'tweets/like_button',
            locals: { tweet: @tweet, current_user: current_user }
          )
        }
      end
    else
      redirect_to tweets_path, alert: 'Unable to unlike tweet.'
    end
  end

  private

  def set_tweet
    @tweet = Tweet.find(params[:tweet_id])
  end
end
