# FactoryBot is a library for setting up Ruby objects as test data.
# This factory defines how to create a Like object for use in tests.
#
# Using `association :user` and `association :tweet` tells FactoryBot to automatically
# create and associate a User and a Tweet when building a Like.
# This is different from `user { nil }`, which would leave the association empty (nil).
# With associations, the Like will always have valid related objects by default.
FactoryBot.define do
  factory :like do
    association :user
    association :tweet
  end
end
