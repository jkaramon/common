require 'capybara'

class Capybara::Driver::Selenium
  
  # Saves png screenshot to the filename
  def save_screenshot(filename)
    base64_png = bridge.getScreenshot
    png_string = Base64.decode64(base64_png)
    File.open(filename, 'wb') {|f| f.write(png_string) }
  end
  
  private 
  # Returns native webdriver  bridge 
  def bridge
    browser.instance_variable_get('@bridge')
  end

end

