    def connect_to_db()
    db = SQLite3::Database.new("db/databas_storprojekt.db")
    db.results_as_hash = true
    return db
end

def new_post(user_id)
    headline = params[:headline]
    body = params[:body]
    image = params[:file]
    mainpostID = params[:mainpostID]
    db = connect_to_db()
    db.execute('INSERT INTO Post (heading, text, Image) VALUES (?,?,?)', headline, body, image)  
    # I db browsér har jag subjekt som måste skrivas in under create för att det ska fungera
end

def register_user()
    email = params[:email]
    username = params[:username]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db = connect_to_db()
    db.execute('INSERT INTO User (username, email, password_digest) VALUES (?,?,?)', username, email, password_digest)
end

def thread()
    db = connect_to_db()
    result = db.execute("SELECT PostID, Heading, Text FROM Post WHERE PostID=#{params[:id]} union all SELECT  AnswerID, Heading, Text FROM Answer WHERE PostID=#{params[:id]}")
    return result   
end

def login()
    db = connect_to_db()
    result= db.execute("SELECT id, password_digest FROM User WHERE email=?", params["username"])

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

def show_all_posts()
    db = connect_to_db()
    result = db.execute("SELECT PostID, Heading, Text FROM Post")
    return result
end