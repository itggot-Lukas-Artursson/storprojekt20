require 'sinatra'
require 'slim'
require 'sqlite3'

get('/') do
    slim(:index)
end

get('/login') do
    slim(:login)
end