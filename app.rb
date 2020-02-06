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

post('/login') do
    result= db.execute("SELECT id, password_digest FROM users WHERE email=?", params[email])
    
    if BCrypt::Password.new(result.first["password_digest"]) == params[:password]
        session[:user_id] = result.first["id"]
        redirect('/')
    else
        redirect('/')
    end
end

get('/register') do
    slim(:register)
end


#     slim(:login)

#     username = params[:username]
#     password = params[:password]
#     password_digest = BCrypt::Password.create(password)
#     db.execute('INSERT INTO USER (username, password) VALUES (?,?)', username, password_digest)
# end

