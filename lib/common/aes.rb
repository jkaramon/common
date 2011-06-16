module AES

  def self.encrypt(key, text)
    self.aes(:encrypt, key, text)
  end

  def self.decrypt(key, text)
    self.aes(:decrypt, key, text)
  end

private
  def self.aes(m,k,t)
    (aes = OpenSSL::Cipher::Cipher.new('aes-256-cbc').send(m)).key = Digest::SHA256.digest(k)
    aes.update(t) << aes.final
  end

end
