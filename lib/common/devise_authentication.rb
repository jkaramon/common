module DeviseAuthentication 

  def find_for_database_authentication(conditions)
    login_name = conditions.delete(:login) || conditions.delete(:username) || conditions.delete(:email)
    self.where(
      '$or' => [ 
        { :username => /^#{login_name}$/i }, 
        { :email    => /^#{login_name}$/i } 
    ] 
    ).first
  end


end

