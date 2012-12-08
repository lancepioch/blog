import sys.db.Types;

class Blog {
    private static var cnx : Null<sys.db.Connection>;
    public static var db = "mysql";

    public static var host = "localhost";
    public static var user = "root";
    public static var pass = "";
    public static var dbname = "haxe";

    private static var test = true;

    public static function main() {
        Blog.connectDatabase();
        Blog.setupDatabase();
        if (Blog.test)
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
        if (Blog.cnx != null)
            throw "Error: Must call connectDatabase before setupDatabase";

        sys.db.Manager.cnx = Blog.cnx;
        
        if (!sys.db.TableCreate.exists(User.manager))
            sys.db.TableCreate.create(User.manager);
        
        if (!sys.db.TableCreate.exists(Section.manager))
            sys.db.TableCreate.create(Section.manager);
        
        if (!sys.db.TableCreate.exists(Post.manager))
            sys.db.TableCreate.create(Post.manager);
        
        if (!sys.db.TableCreate.exists(Comment.manager))
            sys.db.TableCreate.create(Comment.manager);
    }

    public static function testDatabase() {
        var users = new Array<User>();

        // Set up our test users
        users.push(new User());
        users.push(new User());

        users[0].name = "Lance Pioch";
        users[0].admin = true;

        users[1].name = "Derp A. Herp";

        // Insert these two users into our database
        users[0].insert();
        users[1].insert();
    }
}

class User extends sys.db.Object {
    public var id : SId;
    public var name : SString<32>;
    public var birthday : SDate;
    public var admin : SBool = false;
}

class Section extends sys.db.Object {
    public var id : SId;
    public var title : SString<50>;
    public var weight : SInt;
}

class Post extends sys.db.Object {
    public var id : SId;
    public var sectionId : SInt;
    public var userId : SInt;
    public var title : SString<100>;
    public var body : SText;
    public var created : SDateTime;
    public var changed : SDateTime;

    public function new() {
        created = Date.now();
        changed = created;
        super();
    }

    override function update() : Void {
        changed = Date.now();
        return super.update();
    }

    public function getComments(postId : Int) : List<Comment> {
        return Comment.manager.search($postId == postId);
    }
}

class Comment extends sys.db.Object {
    public var id : SId;
    public var postId : SInt;
    public var parentId : SNull<SInt>;
    public var userId : SInt;
    public var body : SString<500>;
    public var created : SDateTime;
    public var changed : SDateTime;

    public function new() {
        created = Date.now();
        changed = created;
        super();
    }

    override function update() : Void {
        changed = Date.now();
        return super.update();
    }
}