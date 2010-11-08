module Regex
  EMAIL = /\A[\w\.%\+\-]+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\z/i
  
  
  PHONE = /^(\+\d)*\s*/i
  
  # should be valid email for now
  USERNNAME = EMAIL

  # Alphanumeric, starts with an alphabet and contains no special characters other than underscore or dash
  SUBDOMAIN = /^([a-zA-Z])[a-zA-Z_-]*[\w_-]*[\S]$|^([a-zA-Z])[0-9_-]*[\S]$|^[a-zA-Z]*[\S]$/i

end