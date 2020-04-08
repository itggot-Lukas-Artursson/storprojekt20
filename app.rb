
require 'sinatra'
require 'bcrypt'
require 'slim'
require 'sqlite3'
require_relative './model.rb'

db = SQLite3::Database.new("db/databas_storprojekt.db")
db.results_as_hash = true   

get('/') do
    result = show_categories()
    slim(:index,locals:{categories:result})
end

get('/login') do
    slim(:"user/login")
end

get('/login_error') do
    slim(:"user/login_error")
end 

get('/login_ok') do
    slim(:"user/login_ok")
end

get('/show_all') do
    result = show_all_posts()
    slim(:"post/show_all",locals:{posts_all:result})
end

post('/login') do
    id = login(params[:username], params[:password])
    if id == -1 
        redirect('/login_error?error=wrong_email')
    elsif id == -2
        redirect('/login_error?error=wrong_password')
    else
        redirect('/login_ok')
    end
end

post('/register_user') do
    register_user()
end

get('/register_user') do
    slim(:"user/register_user")
end

get('/show_thread') do
    result = thread(params[:id])
    result_a = answer(params[:id])
    slim(:"post/thread",locals:{thread_all:result, answer_all:result_a})
    # slim(:thread)
end

post('/new_post') do
    new_post(1,params[:headline], params[:body], params[:image])
    redirect('/post/show_all')
end

get('/new_post') do
    slim(:"post/new_post")
end

post('/upload_image') do

    #Skapa en sträng med join "./public/uploaded_pictures/cat.png"
    path = File.join("./public/uploaded_pictures/",params[:file][:filename])
    
    #Skriv innehållet i tempfile till path
    File.write(path,File.read(params[:file][:tempfile]))
    
    redirect('/post/new_post')
   end

post('/comment') do 
    comment(params[:comment])
    redirect('/post/thread')
end


get('/comment') do
    slim(params[:id])
end 


get('/show_category_posts') do
    result = show_category_posts(params[:id])
    category_name = get_category_name(params[:id])
    slim(:"category/show_category_posts",locals:{category_posts:result, category_name:category_name})
    # slim(:thread)
end



#     slim(:login)

#     username = params[:username]
#     password = params[:password]
#     password_digest = BCrypt::Password.create(password)
#     db.execute('INSERT INTO USER (username, password) VALUES (?,?)', username, password_digest)
# end



