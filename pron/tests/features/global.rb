Given /^I am on "([^"]*)"$/ do |url|
	visit(url)
end

Given /^I am logged in as "([^"]*)"$/ do |login|
	visit("/Account/LoginAs?login=#{login}")
end

Given /^I logged out$/ do |login|
	visit("/Account/Logout")
end
 
When /^I log in as "([^"]*)"$/ do |login|
	visit("/Account/LoginAs?login=#{login}")
end

When /^I log in as "([^"]*)" with password "([^"]*)"$/ do |username, password|
  visit("/Account/Login")
  fill_in("UsernName", :with => username)
  fill_in("Password", :with => password)
end

When /^I log out$/ do
	visit("/Account/Logout")
end

When /^I fill in "([^"]*)" with "([^"]*)"$/ do |field, value|
	fill_in(field, :with => value)
end

When /^I visit "([^"]*)"$/ do |url|
	visit(url)
end
 
When /^I visit link "([^"]*)"$/ do |link|
	click_link(link)
end

When /^I click on "([^"]*)"$/ do |button|
	click_button(button)
end

When /^I press "([^"]*)"$/ do |button|
	click_button(button)
end
 

Then /^I should see "([^"]*)"$/ do |text|
	page.should have_content(text)
end

Then /^I should not see "([^"]*)"$/ do |text|
	page.should_not have_content(text)
end

Then /^I take screenshot$/ do
	# Capybara::Screenshot.screen_shot_and_open_image
	Capybara::Screenshot.screen_shot_and_save_page 
end

When /^I wait for (\d+) seconds?$/ do |secs|
  sleep secs.to_i
end