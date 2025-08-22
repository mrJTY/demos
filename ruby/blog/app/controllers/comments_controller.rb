# CommentsController handles the creation of comments for posts
class CommentsController < ApplicationController
    # Before any action, set the @post instance variable
    # This line tells Rails to run the set_post method before any action in this controller.
    # It ensures that @post is set based on the post_id in the URL parameters.
    before_action :set_post

    # POST /posts/:post_id/comments
    # Creates a new comment associated with the current post
    def create
        # Strong parameters are a Rails feature that helps prevent mass-assignment vulnerabilities
        # by requiring and permitting only specific parameters from the user input.
        # For example, to use strong parameters for a comment:
        # @post.comments.create!(comment_params)
        # where comment_params is defined as:
        # def comment_params
        #   params.require(:comment).permit(:content)
        # end
        # This ensures only the :content attribute is allowed for mass assignment.
        # By calling @post.comments.create!, the new comment is automatically associated with @post
        @post.comments.create!(params.require(:comment).permit(:content))
        # Redirect back to the post show page after creation
        redirect_to @post
    end

    private
        # Finds the post based on the post_id from the params
        def set_post
            # The @ symbol denotes an instance variable in Ruby.
            # Instance variables are accessible throughout the instance of the class (in this case, the controller and its views).
            @post = Post.find(params[:post_id])
        end
end
