module Model
db = SQLite3::Database.new("db/databas_storprojekt.db")
db.results_as_hash = true 

    # Connects to DB
    #
    # @return [db] 
    def connect_to_db()
        db = SQLite3::Database.new("db/databas_storprojekt.db")
        db.results_as_hash = true
        return db
    end
	
    # Register new user
    #
    # @return [Integer] The ID of the user
	def user_register()
        email = params[:email]
        username = params[:username]
        password = params[:password]
        password_digest = BCrypt::Password.create(password)
        db = connect_to_db()
        result = db.execute("SELECT Username from user where Username=? or email=?", username, email)
        if result.empty?
            db.execute('INSERT INTO User (Username, Email, Password_digest) VALUES (?,?,?)', username, email, password_digest)
            userid = query_db_one('SELECT last_insert_rowid() as Result',db)
            db.execute('INSERT INTO Relation_user_userrole (Userid, Roleid) VALUES (?,1)', userid)
        else
            session[:error]="User already exists"
            redirect('/')
        end
    end

    # Login user
    #
	# @param [String] email Email of user
	# @param [String] password Password
    #
    # @return [Integer] The ID of the user
    def login(email, password)
        db = connect_to_db()
        result= db.execute("SELECT Userid, Password_digest FROM User WHERE email=?", email)

        if result.empty?
            return -1
        end

        if BCrypt::Password.new(result.first["Password_digest"]) == password
            session[:userid] = result.first["Userid"]
            session[:admin] = get_admin_role(result.first["Userid"])
            return result.first["id"]
        else 
            return -2       
        end
    end 


    # Find out if user is admin
    #
	# @param [Integer] userid, User id
    #
    # @return 0 Not admin
    # @return 1 User is admin
    def get_admin_role(userid)
        db = connect_to_db()
        result = db.execute("SELECT Roleid FROM Relation_user_userrole WHERE Roleid=2 and userid=?", userid)
        if result.empty?
            return 0
        else
            return 1
        end
    end

    # Create new category
    #
	# @param [String] name Category name
    def category_new(name)
        db = connect_to_db()
        db.execute("INSERT INTO Category (Name) VALUES (?)", name) 
    end 

    # Delete category
    #
	# @param [Integer] id Category id
    def category_delete(id)
        db = connect_to_db()
        result = db.execute("DELETE FROM Category WHERE Categoryid=?",id)
        result = db.execute("DELETE FROM Relation_post_category WHERE Categoryid=?",id)
    end 

    # Create new post
    #
	# @param [Integer] userid User id
	# @param [String] headline Headline of the post
	# @param [String] body Text of the post
	# @param [String] categoryid Category id
    #
    # @return [Integer] The ID of the new post
    def post_new(userid, headline, body, categoryid)
        db = connect_to_db()
        db.execute("INSERT INTO Post (Userid, heading, text) VALUES (?,?,?)", userid, headline, body) 
        postid = query_db_one('SELECT last_insert_rowid() as Result',db)
        category_connect_to_post(postid, categoryid)
        return postid  
    end

    # Edit a post
    #
	# @param [Integer] postID Post id
	# @param [String] text Text of the post
    def post_edit(postID, text)
        db = connect_to_db()
        db.execute("UPDATE Post SET Text=? WHERE Postid=?",text,postID)
    end

    # Create new post
    #
	# @param [Integer] id Post id
    def post_delete(id)
        db = connect_to_db()
        db.execute("DELETE FROM Post WHERE Postid=?",id)
        db.execute("DELETE FROM Relation_post_category WHERE PostId=?", id)
    end 


    # Info about a post
    #
	# @param [String] id, Post id
	#
    # @return [Hash]
    #   * :Postid [Integer] The ID of the post
    #   * :Heading [String] The title of the post
    #   * :Text [String] The content of the post
    #   * :Username [String] The name of the user
    #   * :Userid [Integer] The ID of the user
    def post_info(id)
        db = connect_to_db()
        result = db.execute("SELECT Postid, Heading, Text, Username, u.Userid FROM Post p inner join User u ON p.Userid=u.Userid WHERE Postid=#{id}")
        session[:postid] = id
        return result   
    end

    # Info about answers connected to a post
    #
	# @param [String] id, Post id
	#
    # @return [Array]
    #   * :Answerid [Integer] The ID of the answer 
    #   * :Text [String] The content of the answer
    #   * :Username [String] The name of the user that posted the answer
    #   * :Userid [Integer] The ID of the user that posted the answer
    def answer_info(id)
        db = connect_to_db()
        result = db.execute("SELECT Answerid, Text, Username, u.Userid FROM Answer a inner join User u ON a.Userid=u.Userid WHERE Postid=#{id}")
        return result   
    end


    # List all categories
    #
    # @return [Array]
    #   * :Categoryid [Integer] The ID of the answer 
    #   * :Name [String] The content of the answer
    def get_categories()
        db = connect_to_db()
        result = db.execute("SELECT Categoryid, Name FROM Category")
        return result
    end


    # Connect category to post
    #
	# @param [Integer] postid Post id
	# @param [Integer] categoryid Category id
    def category_connect_to_post(postid, categoryid)
        db = connect_to_db()
        db.execute("INSERT INTO Relation_post_category (PostId, CategoryId) VALUES (?,?)", postid, categoryid) 
    end


    # Connect category to post
    #
	# @param [Integer] postid, Post id
	# @param [Integer] categoryid, Category id
	#
    # @return false	Category can not be disconnected
    # @return true	Category can be disconnected
    def category_disconnect_from_post(postid, categoryid)
        db = connect_to_db()   
        relationsCount = db.execute("SELECT count(*) FROM Relation_post_category WHERE PostId=?", postid)
        if relationsCount.first[0] == 1
            return false
        else
            db.execute("DELETE FROM Relation_post_category WHERE PostId=? AND CategoryId=?", postid, categoryid)
            return true
        end
    end


    # Get all categories that are connected to apost
    #
	# @param [Integer] postid, Post id
	#
    # @return [Array]
    #   * :Categoryid [Integer] The ID of the answer 
    #   * :Name [String] The content of the answer
    #   * :PostId [Integer] The ID of the post. If nil the category is not connected
    def get_categories_from_postid(postid)
        db = connect_to_db()
        result = db.execute("SELECT c.Categoryid, Name, r.PostId FROM Category c LEFT OUTER JOIN Relation_post_category r ON (c.Categoryid=r.CategoryId and r.PostId=?)",postid)
        return result
    end


    # Get all posts that are connected to a category
    #
	# @param [Integer] categoryid, Category id
	#
    # @return [Array]
    #   * :PostId [Integer] The ID of the post.
    #   * :Heading [String] The heading of the post.
    def get_posts(categoryid)
        db = connect_to_db()
        result = db.execute("SELECT p.Postid, Heading FROM Post p inner join Relation_post_category r ON p.Postid= r.postID WHERE r.Categoryid=? ",categoryid)
        return result
    end
    
    # Get info about a category
    #
	# @param [Integer] categoryid, Category id
	#
    # @return [Hash]
    #   * :Name [String] The name of the category.
    #   * :Categoryid [Integer] The ID of the category.
    def get_category_info(categoryid)
        db = connect_to_db()
        result = db.execute("SELECT Name, Categoryid FROM Category WHERE Categoryid=?",categoryid)
        return result
    end

    # Create new answer to post
    #
	# @param [String] text, Text of the answer
	#
    # @return [Hash]
    #   * :Name [String] The name of the category.
    #   * :Categoryid [Integer] The ID of the category.
    def answer_new(text)
        postid = session[:postid]
        userid = session[:userid]
        db = connect_to_db()
        db.execute("INSERT INTO Answer (Text, Userid, Postid) VALUES (?,?,?)", text, userid, postid)
    end

    # Delete answer to post
    # @param [Integer] answerid The ID of the answer
    def answer_delete(answerid)
        db = connect_to_db()
        db.execute("DELETE FROM Answer WHERE Answerid=?",answerid)
    end 

    # Get answer text
    #
	# @param [Integer] answerid, The ID of the answer
	#
    # @return [String] The text of the answer
    def get_answer_text(answerid)
        db = connect_to_db()
        result = db.execute("SELECT Text FROM Answer WHERE Answerid=?",answerid)
        return result.first["Text"]
    end

    # Get post text
    #
	# @param [Integer] postid, The ID of the post
	#
    # @return [String] The text of the post
    def get_post_text(postid)
        db = connect_to_db()
        result = db.execute("SELECT Text FROM Post WHERE Postid=?",postid)
        return result.first["Text"]
    end

    # Update answer text
    #
    # @param [Integer] answerid The ID of the answer
    # @param [String] text The text of the answer
    def answer_edit(answerid, text)
        db = connect_to_db()
        db.execute("UPDATE Answer SET Text=? WHERE Answerid=?",text,answerid)
    end


    # Get a single value from DB
    #
	# @param [String] query The database query
    # @param [Integer] db The database connection
    #
    # @return [String] The text of the post
    def query_db_one(query,db)
        cursor = db.execute query
        temp = cursor[0]
        return temp[0]
    end

    # Validation of fields
    #
	# @param [Integer] type Type of validation
	# @param [String] check_value Value to validate
    def validate(type, check_value) 
        if type==1   
            if check_value.include?("@")
                return
            else  
                session[:error]="Email missing @"
                redirect back
            end
        elsif type==2
            if check_value.empty? == false
                return
            else  
                session[:error]="You must fill in all fields"
                redirect back
            end
        end
    end

end