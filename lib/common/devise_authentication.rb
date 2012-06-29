module DeviseAuthentication 

  def find_for_database_authentication(conditions)
    login_name = conditions.delete(:login) || conditions.delete(:username) || conditions.delete(:email)
    self.where(
      '$or' => [ 
        { :username => /^#{Regexp.escape(login_name)}$/i }, 
        { :email    => /^#{Regexp.escape(login_name)}$/i } 
      ] 
    ).first
  end

  def send_reset_password_instructions(attributes={})
    recoverable = find_for_database_authentication(attributes)
    recoverable.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end
  
end

