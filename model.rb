def connect_to_db()
    db = SQLite3::Database.new("db/databas_storprojekt.db")
    db.results_as_hash = true
    return db
end

def new_post(user_id, headline, body, image)
    db = connect_to_db()
    db.execute('INSERT INTO Post (UserID, heading, text, Image) VALUES (?,?,?,?)', user_id, headline, body, image)  
    # I db browsér har jag subjekt som måste skrivas in under create för att det ska fungera
end

def register_user()
    email = params[:email]
    username = params[:username]
    password = params[:password]
    password_digest = BCrypt::Password.create(password)
    db = connect_to_db()
    result = db.execute("SELECT username from user where username=? or email=?", username, email)
    # result = db.execute o0("SELECT username from user where username='#{username}'")
    if result.empty?
        db.execute('INSERT INTO User (username, email, password_digest) VALUES (?,?,?)', username, email, password_digest)
    else
        redirect('/login_error?error=already_registered')
    end
end

def thread(id)
    db = connect_to_db()
    result = db.execute("SELECT PostID, Heading, Text FROM Post WHERE PostID=#{id} union all SELECT  AnswerID, Heading, Text FROM Answer WHERE PostID=#{id}")
    return result   
end

def login(username, password)
    db = connect_to_db()
    result= db.execute("SELECT id, password_digest FROM User WHERE email=?", username)

    if result.empty?
       return -1
    end
 
    if BCrypt::Password.new(result.first["password_digest"]) == password
        # session[:user_id] =
        return result.first["id"]
    else 
        return -2
       
    end
end

def show_all_posts()
    db = connect_to_db()
    result = db.execute("SELECT PostID, Heading, Text FROM Post")
    return result
end

