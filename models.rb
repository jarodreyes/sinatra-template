DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.sqlite")

class User 
  include DataMapper::Resource
  
  attr_accessor :password, :password_confirmation

  property :id,             Serial
  property :email,          String,     :required => true, :unique => true, :format => :email_address
  property :name,       String
  property :nickname,   String
  property :password_hash,  Text  
  property :password_salt,  Text
  property :token,          String
  property :created_at,     DateTime
  property :admin,             Boolean,    :default => false
  property :email_confirmation ,		          Boolean,  :default => false
  property :email_code ,      String

  
  validates_presence_of         :password
  validates_confirmation_of     :password
  validates_length_of           :password, :min => 6

  after :create do
    self.token = SecureRandom.hex
    self.email_code =  SecureRandom.hex
  end
  
  def generate_token
    self.update!(:token => SecureRandom.hex)
  end

  def admin?
    self.admin
  end
  
  def send_email_confirmation
    body = <<-EOHTML
     Hello #{self.name}!
     
     You just signed up for P&R Please follow this link to confirm that this is your e-mail address.
     http://#{ENV['URL']}/confirmation/#{self.email_code }

     Thanks,
     The P&R Team
     EOHTML
     
    Pony.mail({:to => self.email,
      :from => 'no@nocaount.com',
      :subject => 'P&R Account Confirmation',
      :body => body,
      :via => :smtp,
      :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '587',
        :domain => 'heroku.com',
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :authentication => :plain,
        :enable_starttls_auto => true
        }
      })
  end
  
  def self.authenticate(email, pass)
    u = User.first(:email => email)
    if u.nil?
      nil
    elsif u.password_hash != BCrypt::Engine.hash_secret(pass, u.password_salt) 
        nil
    elsif u.email_confirmation == false 
      nil
    else
      u 
    end
  end

  has n, :authenfications
  has n, :partnerships, :child_key => [ :source_id ]
  has n, :partners, self, :through => :partnerships, :via => :target
end

class Authenfication
  include DataMapper::Resource
  
  property :id,         Serial
  property :uid,        String
  property :created_at, DateTime
  
  belongs_to :user
end

class Partnership
   include DataMapper::Resource
   
   belongs_to :source, 'User', :key => true
   belongs_to :target, 'User', :key => true
end

DataMapper.finalize
DataMapper.auto_upgrade!