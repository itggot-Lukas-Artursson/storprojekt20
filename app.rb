require 'sinatra'
require 'bcrypt'
require 'byebug'
require 'slim'
require 'sqlite3'
require_relative './model.rb'
include Model

enable :sessions 

# Show all categories
#
# @see Model#get_categories
get('/') do
    result = get_categories()
    slim(:"categories/index",locals:{categories:result})
end

# Show login page
#
get('/login') do
    slim(:"user/login")
end


# Login user and set session value of userid
#
# @param [String] email Email of user
# @param [String] password Password
#
# @see Model#login 
post('/login') do    
    if session[:logintime] != nil
        if (Time.now.to_i - session[:logintime]) < 10
            session[:error]="Please wait 10 seconds between login attempts "
            session[:logintime]=Time.now.to_i
            redirect('/login')
        end
    end

    session[:logintime]=Time.now.to_i

    id = login(params[:email], params[:password])
    if id == -1 
        session[:error]="Wrong email"
        redirect('/login')
    elsif id == -2
        session[:error]="Wrong password"
        redirect('/login')
    else
        session[:error]=nil
        redirect('/')
    end
end

# Show user registration form  
#
get('/user/register') do
    slim(:"user/register")
end

# New user registration with validation of fields
#
# @param [String] email, Email of user
# @param [String] username, User name
# @param [String] password, Password
#
# @see Model#user_register 
post('/user/register') do
    validate(1, params[:email])
    validate(2, params[:email])
    validate(2, params[:username])
    validate(2, params[:password])
    user_register()
    session[:error]=nil
    redirect('/login')
end


# Show new category form  
#
get('/categories/new') do 
    slim(:"categories/new")
end


# Show category info and all connected posts 
#
# @param [Integer] :id, Category Id
#
# @see Model#get_posts 
# @see Model#get_category_info 
get('/categories/:id') do
    posts = get_posts(params[:id])
    category_info = get_category_info(params[:id])
    slim(:"categories/get_posts",locals:{category_posts:posts, category_info:category_info})
end

# Show page for creating a new post in a category
#
# @param [Integer] :id, Category Id
get('/categories/:id/new_post') do
    slim(:"posts/new", locals:{id:params[:id]})
end

# Delete a category 
#
# @param [Integer] :id, Category Id
#
# @see Model#category_delete 
get('/categories/:id/delete') do 
    category_delete(params[:id])
    redirect back
end

# Create a new category 
#
# @param [String] name, Category name
#
# @see Model#category_new 
post('/categories/new') do 
    category_new(params[:name])
    redirect('/')
end

# Show a thread with posts and answers
#
# @param [Integer] :id, Post Id
#
# @see Model#post_info 
# @see Model#answer_info 
get('/posts/:id') do
    result_post = post_info(params[:id])
    result_answer = answer_info(params[:id])
    slim(:"posts/thread",locals:{thread_all:result_post, answer_all:result_answer})
end

# Create a new post 
#
post('/posts/new') do
    if session[:userid].nil?
        slim(:"user/login")
    end
    postid = post_new(session[:userid] ,params[:headline], params[:body], params[:categoryid])
    redirect("/posts/" + postid.to_s + "/add_category")
end

# Show all categories and if they are connected to a specific post
#
# @param [Integer] id, Post Id
# @param [String] headline, Headline of the post
# 
# @see Model#category_disconnect_from_post
get('/posts/:id/add_category') do
    categories = get_categories_from_postid(params[:id])
    slim(:"posts/add_category",locals:{postid:params[:id], headline:params[:headline], categories:categories})
end

# Connects a post to a category
#
# @param [Integer] postid, Post Id
# @param [Integer] categoryid, Category Id
# 
# @see Model#category_connect_to_post
get('/posts/:postid/connect/:categoryid') do
    category_connect_to_post(params[:postid], params[:categoryid])
    redirect back
end

# Disconnects a post from a category
#
# @param [Integer] :postid, Post Id
# @param [Integer] :categoryid, Category Id
# 
# @see Model#category_disconnect_from_post
get('/posts/:postid/disconnect/:categoryid') do
    result=category_disconnect_from_post(params[:postid], params[:categoryid])
    if result==false
        session[:error]="Can't disconnect all categories"
    end        
    redirect back
end

# Delete a post
#
# @param [Integer] :id, Post Id
# 
# @see Model#post_delete
get('/posts/:id/delete') do 
    post_delete(params[:id])
    redirect('/')
    # redirect(session[:requester])
end


# Show page for editing post
#
# @param [Integer] :id, Post Id
# 
# @see Model#get_post_text
get('/posts/:id/edit') do 
    result = get_post_text(params[:id])
    slim(:"posts/edit", locals:{answerid:(params[:id]), text:result})
end


# Update a post
#
# @param [Integer] :id, Post Id
# @param [String] text, Updated text on the post
# 
# @see Model#post_edit
post('/posts/:id/edit') do 
    post_edit(params[:id], params[:text])
    redirect(session[:requester])
end


# Add a new answer to a post
#
# @param [Integer] id, Post Id
# 
# @see Model#answer_new
post('/posts/:id/answer_new') do 
    answer_new(params[:text])
    redirect(request.referer)
end

# Delete a answer to a post
#
# @param [Integer] answerid, Answer Id
# 
# @see Model#answer_delete
get('/posts/:id/answer_delete/:answerid') do 
    answer_delete(params[:answerid])
    redirect(request.referer)
end

# Show page to edit an answer
#
# @param [Integer] id, Post Id
# @param [Integer] answerid, Answer Id
# 
# @see Model#get_answer_text
get('/posts/:id/answer_edit/:answerid') do 
    result = get_answer_text(params[:answerid])
    slim(:"answer/edit", locals:{answerid:(params[:answerid]), text:result})
end

# Updates an answer
#
# @param [Integer] id Answer Id
# @param [String] text Updated text on the answer
# 
# @see Model#answer_edit
post('/answer/:id/edit') do 
    answer_edit(params[:id], params[:text])
    redirect(session[:requester])
end


# Logout user and clean session
# 
get('/logout')do
    session[:userid] = nil
    session[:logintime] = nil
    redirect('/')
end
