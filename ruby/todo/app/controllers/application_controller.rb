class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Devise redirect after sign in
  def after_sign_in_path_for(resource)
    todos_path
  end
end
