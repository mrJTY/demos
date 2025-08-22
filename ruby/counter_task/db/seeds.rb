# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
# This line ensures that there is always a Counter record with id: 1 in the database.
# If it doesn't exist, it will be created with a value of 0.
Counter.find_or_create_by(id: 1) { |c| c.value = 0 }
