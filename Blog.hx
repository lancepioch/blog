import sys.db.Types;

class Blog {
    private static var cnx : Null<sys.db.Connection>;
    public static var db = "mysql";

    public static var host = "localhost";
    public static var user = "root";
    public static var pass = "";
    public static var dbname = "haxe";

    private static var testing = true;

    public static function main() {
        Blog.connectDatabase();
        Blog.setupDatabase();
        if (Blog.testing)
            Blog.testDatabase();
        Blog.disconnectDatabase();
    }

    public static function connectDatabase() {
        if (Blog.db == "mysql")
            cnx = sys.db.Mysql.connect({ 
                host : Blog.host,
                port : 3306,
                user : Blog.user,
                pass : Blog.pass,
                socket : null,
                database : Blog.dbname
            });
        else if (Blog.db == "sqlite")
            cnx = sys.db.Sqlite.open(dbname + ".db");
        else
            throw "Error: Must select valid database type.";
    }

    public static function disconnectDatabase() {
        if (Blog.cnx != null)
            Blog.cnx.close();
        Blog.cnx = null;
    }

    public static function setupDatabase() {
        if (Blog.cnx == null)
            throw "Error: Must call connectDatabase before setupDatabase";

        sys.db.Manager.cnx = Blog.cnx;
        sys.db.Manager.initialize();
        
        if (!sys.db.TableCreate.exists(User.manager))
            sys.db.TableCreate.create(User.manager);
        
        if (!sys.db.TableCreate.exists(Section.manager))
            sys.db.TableCreate.create(Section.manager);
        
        if (!sys.db.TableCreate.exists(Post.manager))
            sys.db.TableCreate.create(Post.manager);
        
        if (!sys.db.TableCreate.exists(Comment.manager))
            sys.db.TableCreate.create(Comment.manager);
    }

    public static function createSection(title : String, weight : Int = 0) : Section {
        var section = new Section();
        section.title = title;
        section.weight = weight;
        section.insert();
        return Section.manager.get(section.id);
    }

    public static function getSections() : List<Section> {
        return Section.manager.all();
    }

    public static function getUsers() : List<User> {
        return User.manager.all();
    }

    public static function getUser(userId : Int) : User {
        return User.manager.select($id == userId);
    }
    
    public static function createUser(name : String, email : String, admin : Bool = false) : User {
        var user = new User();
        user.name = name;
        user.email = email;
        user.admin = admin;
        user.insert();
        return User.manager.get(user.id);
    }

    public static function testDatabase() {
        var users = new Array<User>();

        for (i in 0...3) // push number of test users below
            users.push(new User());

        users[0] = Blog.createUser("Lance Pioch", "lance@lancepioch.com", true);
        users[1] = Blog.createUser("Derp A. Herp", "derpaherp@example.com");
        users[2] = Blog.createUser("The Man", "theman@example.com");
        users[3] = Blog.createUser("Snoo Reddit", "reddit@example.com");

        var section = Blog.createSection("Main");
        var post = users[0].createPost("Initial Post", "This is the most awesome post ever!", section);
        var comment = users[1].createComment("You are absolutely right, I can't believe how cool this is.", post);
        var reply = users[0].createComment("Why thank you good sir!", post, comment);

        reply = users[1].createComment("No problem, have a nice day.", post, reply);
        reply = users[0].createComment("Thanks, you too.", post, reply);
        comment = users[3].createComment("This is interesting...", post);
        users[0].createComment("You really think so!?", post, comment);
        reply = users[2].createComment("I'm the man and I'm here to put you down!", post, comment);
        comment = users[0].createComment("Hey, no spamming in my blog, when I get back you are going to be banned.", post, reply);
        reply.delete();
        users[0].createComment("Done and done", post, comment);

        trace(post);
    }

    public static function toString() : String {
        var output = "Sections: ";
        var sections = Blog.getSections();

        for (section in sections) {
            output += section.title + "\n";
        }

        return output;
    }

    public static function getDeletedMessage() : String {
        return "This post has been deleted.";
    }
}