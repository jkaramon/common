module DeviseAuthenticatable 

  def valid_password?(incoming_password)
    return false if password_digest(incoming_password).nil?
    return false if self.encrypted_password.nil?
    super(incoming_password)
  end

end
