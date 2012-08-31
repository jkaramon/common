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

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_error_by(:username, attributes[:username], :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end
 
  def self.send_confirmation_instructions(attributes={})
    confirmable = find_or_initialize_with_error_by(:username, attributes[:username], :not_found)
    confirmable.resend_confirmation_token if confirmable.persisted?
    confirmable
  end

end
