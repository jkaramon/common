module DeviseAuthentication 
  
  def find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    self.where(
      '$or' => [ 
        { :username => /#{login}/i }, 
        { :email    => /#{login}/i } 
      ] 
    ).first
  end
    
  
end

