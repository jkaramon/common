require 'mail'
require 'mail/encodings'
  	

Mail::Ruby19.class_eval do 
  def self.q_value_decode(str)
    match = str.match(/\=\?(.+)?\?[Qq]\?(.+)?\?\=/m)
    if match
      encoding = match[1]
      str = Mail::Encodings::QuotedPrintable.decode(match[2])
      str = Iconv.iconv('UTF-8', encoding, str)[0]
    end
    str
  end
end # Ruby19 class
