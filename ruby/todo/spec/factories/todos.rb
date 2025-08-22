FactoryBot.define do
  factory :todo do
    title { "Sample Todo" }
    description { "This is a sample todo for testing" }
    completed { false }
    priority { 1 }
    user
  end
end
