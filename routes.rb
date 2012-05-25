get "/" do
  if session[:access_token] 
    #cherche le user
    graph  = Koala::Facebook::API.new(session[:access_token])
    user_fb  = graph.get_object("me")
    #create an Authenfication
    authentication = Authenfication.first(:uid => user_fb["id"])
    unless authentication
     #create user
     user = User.new
     user.email = user_fb['email']
     user.created_at = Time.now
     user.token =  SecureRandom.hex
     user.nickname = user_fb["username"]
     user.name = user_fb["name"] 
     user.email_confirmation = true
     
     authentication = Authenfication.first_or_create({ :uid => user_fb["id"]}, {:uid => user_fb["id"], :created_at => Time.now })
    
     user.authenfications << authentication
     user.save!
    end
    unless authentication
      session[:user] = authentication.user.token 
      response.set_cookie("user", {:value =>  authentication.user.token, :expires => (Time.now + 52*7*24*60*60)}) if params[:remember_me]
    end
  end
  erb :index
end

get "/email" do
  u = User.first
  resp = u.send_email_confirmation
end

get "/signup" do
  erb :signup
end

post "/signup" do
  user = User.create(params[:user])
  user.password_salt = BCrypt::Engine.generate_salt
  user.password_hash = BCrypt::Engine.hash_secret(params[:user][:password], user.password_salt)
  if user.save
    user.send_email_confirmation
    flash[:info] = "Email confirmation has sent" 
    #session[:user] = user.token
    redirect "/" 
  else
    flash[:error] =  user.errors.full_messages.join(",") 
    redirect "/signup?" + hash_to_query_string(params[:user])
  end
end

get '/confirmation/:code' do
  u = User.first(:email_code => params[:code])
  unless u.nil?
    u.email_confirmation = true
    u.save!
    flash[:sucess] = "<strong>Well done!</strong> Sucess signup"
    session[:user] = u.token
  else
    flash[:error] = "Not authorized"
  end
  redirect "/"
end


get "/login" do
  if current_user
    redirect_last
  else
    erb :login
  end
end

post "/login" do
  if user = User.authenticate(params[:email],params[:password])
    session[:user] = user.token 
   response.set_cookie("user", {:value => user.token, :expires => (Time.now + 52*7*24*60*60)}) if params[:remember_me]
    redirect_last
  else
    fash[:error] = "Your are not athorized"
    redirect "/login"
  end
end

get "/logout" do
  current_user.generate_token
  response.delete_cookie "user"
  session[:user] = nil
  session[:access_token] = nil
  flash[:info] = "Successfully logged out"
  redirect "/"
end

get "/secret" do
  login_required
  "This is a secret secret"
end

get "/supersecret" do
  admin_required
  "Well done on being super special. You're a star!"
end

get "/personal/:id" do
  is_owner? params[:id]
  "<pre>id: #{current_user.id}\nemail: #{current_user.email}\nadmin? #{current_user.admin}</pre>"
end

#FACEBOOK



get "/auth/facebook" do
  session[:access_token] = nil
  redirect authenticator.url_for_oauth_code(:permissions => FACEBOOK_SCOPE)
end

get '/auth/facebook/callback' do
	session[:access_token] = authenticator.get_access_token(params[:code])
  graph  = Koala::Facebook::API.new(session[:access_token])
  user_fb  = graph.get_object("me")
  #create an Authenfication
  authentication = Authenfication.first(:uid => user_fb["id"])
  unless authentication
    user = User.new
    user.email = user_fb['email']
    user.created_at = Time.now
    user.token =  SecureRandom.hex
    user.email_confirmation = true
    begin
      authentication = Authenfication.first_or_create({ :uid => user_fb["id"]}, {
           :uid => user_fb["id"],
           :nickname => user_fb["username"], 
           :name => user_fb["name"],
           :created_at => Time.now })
    rescue Exception => e
      flash[:error] =e.message
      redirect '/'
    end
    #save User
    begin
      user.authenfications << authentication
      user.save!
    rescue Exception => e
      flash[:error] =e.message
      redirect '/'
    end
  end
  
  flash[:sucess] = "Signed in successfully."
  session[:user] = authentication.user.token 
  response.set_cookie("user", {:value =>  authentication.user.token, :expires => (Time.now + 52*7*24*60*60)}) if params[:remember_me]
  redirect '/'
end

get '/auth/failure' do
  clear_session
  message = "In order to use this site you must allow us access to your Facebook data<br />'"
  session['fb_error'] = message
  flash[:error] =message
  redirect '/'
end
