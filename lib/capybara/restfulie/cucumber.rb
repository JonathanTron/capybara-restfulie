require 'capybara/restfulie'

Before('@restfulie') do
  Capybara.current_driver = :restfulie
end