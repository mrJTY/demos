// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "./application"

import HelloController from "./hello_controller"
application.register("hello", HelloController)

import TweetFormController from "./tweet_form_controller"
application.register("tweet-form", TweetFormController)
