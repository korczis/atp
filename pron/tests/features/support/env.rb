require 'capybara'
require 'capybara/cucumber'
require 'rspec'
require 'selenium/webdriver'
require 'capybara-screenshot'
require 'fileutils'



Capybara.app_host = "http://localhost:4000"

# IE settings
Capybara.register_driver :ie do |app|
  Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => "http://localhost:5555/",
    :desired_capabilities => :internet_explorer)
end

# Firefox settings 
Capybara.register_driver :firefox do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end

# IE settings
Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app,
    :browser => :remote,
    :url => "http://localhost:9515/",
    :desired_capabilities => :internet_explorer)
end

default_screenshot_driver = Capybara::Screenshot.registered_drivers.fetch(:selenium)
Capybara::Screenshot.registered_drivers[:ie] = default_screenshot_driver
Capybara::Screenshot.registered_drivers[:firefox] = default_screenshot_driver
Capybara::Screenshot.registered_drivers[:chrome] = default_screenshot_driver

# Capybara settings
Capybara.default_wait_time = 5
Capybara::Screenshot.autosave_on_failure = false

# Select your browser here
Capybara.default_driver = :firefox # Can be :chrome, :firefox or :ie

# Setup screenshots
screenshot_folder_name = Time.now.strftime("%Y%m%d_%H%M%S_#{Capybara.default_driver.to_s}")
screenshots_path = File.join(File.dirname(__FILE__), "..", "..", "..", "screenshots", screenshot_folder_name)
if File.exists?(screenshots_path) == false
	FileUtils.mkdir_p(screenshots_path)
end
Capybara.save_and_open_page_path = screenshots_path