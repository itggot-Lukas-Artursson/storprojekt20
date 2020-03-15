require 'sinatra'
require 'bcrypt'
require 'slim'
require 'sqlite3'
require_relative './model.rb'

db = SQLite3::Database.new("db/databas_storprojekt.db")
db.results_as_hash = true   

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end

get('/login_error') do
    slim(:login_error)
end 

get('/login_ok') do
    slim(:login_ok)
end

get('/all_posts') do
    result = show_all_posts()
    slim(:posts,locals:{posts_all:result})
end

post('/login') do
    login()
end

post('/register_user') do
    register_user()
end

get('/register_user') do
    slim(:register_user)
end

get('/thread') do
    result = thread()
    slim(:thread,locals:{posts_all:result})
    # slim(:thread)
end

post('/new_post') do
  new_post('lukas')
end

get('/new_post') do
    slim(:new_post)
end

post('/upload_image') do

    #Skapa en sträng med join "./public/uploaded_pictures/cat.png"
    path = File.join("./public/uploaded_pictures/",params[:file][:filename])
    
    #Skriv innehållet i tempfile till path
    File.write(path,File.read(params[:file][:tempfile]))
    
    redirect('/new_post')
   end


#     slim(:login)

#     username = params[:username]
#     password = params[:password]
#     password_digest = BCrypt::Password.create(password)
#     db.execute('INSERT INTO USER (username, password) VALUES (?,?)', username, password_digest)
# end



