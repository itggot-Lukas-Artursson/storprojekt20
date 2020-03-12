require 'sinatra'
require 'bcrypt'
require 'slim'
require 'sqlite3'

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
    result = db.execute("SELECT ID, Subject, Text FROM Post")
    slim(:posts,locals:{posts_all:result})
end

post('/login') do
    # result= db.execute("UPDATE user SET password_digest='"+BCrypt::Password.create("xy")+"'")

    result= db.execute("SELECT id, password_digest FROM user WHERE email=?", params["username"])

    if result.empty?
        redirect('/login_error?error=user_id')
    end
  
    if BCrypt::Password.new(result.first["password_digest"]) == params["password"]
        session[:user_id] = result.first["id"]
        redirect('/login_ok')
    else
        redirect('/login_error')
    end
end

post('/register') do
    email = params[:email]
    username = params[:username]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db.execute('INSERT INTO USER (username, email, password_digest) VALUES (?,?,?)', username, email, password_digest)
end


get('/register') do
    slim(:register)
end

get('/thread') do
    result = db.execute("SELECT ID, Subject, Text FROM Post WHERE ID=#{params[:id]}")
    slim(:thread,locals:{posts_all:result})
    # slim(:thread)
end


post('/create_post') do
    headline = params[:headline]
    body = params[:body]
    db.execute('INSERT INTO Post (heading, text) VALUES (?,?)', headline, body)  
    # I db browsér har jag subjekt som måste skrivas in under create för att det ska fungera
end

get('/create_post') do
    slim(:create_post)
end

#     slim(:login)

#     username = params[:username]
#     password = params[:password]
#     password_digest = BCrypt::Password.create(password)
#     db.execute('INSERT INTO USER (username, password) VALUES (?,?)', username, password_digest)
# end

