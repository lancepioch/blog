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

class User extends sys.db.Object {
    public var id : SId;
    public var name : SString<32>;
    public var email : SString<64>;
    // public var birthday : SNull<SDate>;
    public var admin : SBool = false;

    public override function toString() {
        if (admin)
            return name + " [A]";
        return name;
    }

    public static function get(userId : Int) : User {
        return User.manager.get(userId);
    }

    public function createPost(title : String, body : String, section : Section) : Post {
        var post = new Post();
        post.title = title;
        post.body = body;
        post.sectionId = section.id;
        post.userId = id;
        post.insert();
        return Post.manager.get(post.id);
    }

    public function createComment(body : String, post : Post, ?parent : Comment) : Comment {
        var comment = new Comment();
        comment.body = body;
        if (parent != null)
            comment.parentId = parent.id;
        comment.postId = post.id;
        comment.userId = id;
        comment.insert();
        return Comment.manager.get(comment.id);
    }
}

class Section extends sys.db.Object {
    public var id : SId;
    public var title : SString<50>;
    public var weight : SInt = 0;

    public function getPosts() : List<Post> {
        return Post.manager.search($sectionId == id);
    }
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

    public override function update() : Void {
        changed = Date.now();
        return super.update();
    }

    public function getUser() : User {
        return User.manager.select($id == userId);
    }

    public function getComments() : List<Comment> {
        return Comment.manager.search($postId == id);
    }

    public function getTopComments() : List<Comment> {
        return Comment.manager.search($postId == id && $parentId == null);
    }

    public override function toString() : String {
        var output = title + " [" + id + "] " + getUser().name + ": " + body;

        for (comment in getTopComments())
            output += comment;

        return output;
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
    public var deleted : SBool = false;

    public function new() {
        created = Date.now();
        changed = created;
        super();
    }

    public override function update() : Void {
        changed = Date.now();
        super.update();
    }

    public override function delete() : Void {
        deleted = true;
        update();
    }

    public function undelete() : Void {
        deleted = false;
        update();
    }

    public function getChildren() : List<Comment> {
        return Comment.manager.search($parentId == id);
    }

    public function getUser() : User {
        return User.manager.select($id == userId);
    }

    public override function toString() : String {
        return toStringHelper();
    }

    private function toStringHelper(depth : Int = 0, showDeleted : Bool = false) : String {
        var output = "\n";
        var prepend = new StringBuf();

        for (i in 0...depth+1)
            prepend.addChar(45); // Char: '-'

        output += prepend + " "
                + getUser().name + ": "
                + ((showDeleted || !deleted) ? body : Blog.getDeletedMessage());

        for (comment in getChildren())
            output += comment.toStringHelper(depth + 1);

        return output;
    }
}