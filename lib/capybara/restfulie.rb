module Capybara
  module Driver
    autoload :Restfulie, 'capybara/driver/restfulie_driver'
  end
end

Capybara.register_driver :restfulie do |app|
  Capybara::Driver::Restfulie.new(app)
end