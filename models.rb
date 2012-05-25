DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.sqlite")

class User 
  include DataMapper::Resource
  
  attr_accessor :password, :password_confirmation

  property :id,             Serial
  property :email,          String,     :required => true, :unique => true, :format => :email_address
  property :password_hash,  Text  
  property :password_salt,  Text
  property :token,          String
  property :created_at,     DateTime
  property :admin,          Boolean,    :default => false
  
  validates_presence_of         :password
  validates_confirmation_of     :password
  validates_length_of           :password, :min => 6

  after :create do
    p "CREATE USER"
    self.token = SecureRandom.hex
  end
  
  def generate_token
    self.update!(:token => SecureRandom.hex)
  end

  def admin?
    self.admin
  end
  
  has n, :authenfications
end

class Authenfication
  include DataMapper::Resource
  
  property :id,         Serial
  property :uid,        String
  property :name,       String
  property :nickname,   String
  property :created_at, DateTime
  
  belongs_to :user

  
end

DataMapper.finalize
DataMapper.auto_upgrade!