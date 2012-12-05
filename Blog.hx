import sys.db.Types;

class Blog {
    public static var db = "mysql";
    static function main() {
        // Open a connection
        var cnx : sys.db.Connection;

        if (Blog.db == "mysql")
            cnx = sys.db.Mysql.connect({ 
                host : "localhost",
                port : 3306,
                user : "root",
                pass : "",
                socket : null,
                database : "haxe"
            });
        else if (Blog.db == "sqlite")
            cnx = sys.db.Sqlite.open("haxe.db");

        // Set as the connection for our SPOD manager
        sys.db.Manager.cnx = cnx;

        // Create the "user" table
        if (!sys.db.TableCreate.exists(User.manager))
            sys.db.TableCreate.create(User.manager);

        var users = new Array<User>();

        // Set up our test users
        users.push(new User());
        users.push(new User());

        users[0].name = "Lance Pioch";
        //             = new Date(year,mo,dy,h,m,s);
        users[0].birthday = new Date(1993,02,03,0,0,0);
        users[0].phoneNumber = "(419) 556 1337";
        // users[0].admin = true;

        users[1].name = "Derp A. Herp";
        users[1].birthday = new Date(1990,02,21,0,0,0);
        users[1].phoneNumber = null;

        // Insert these two users into our database
        users[0].insert();
        users[1].insert();
        
        // Close the connection
        cnx.close();
    }
}

class User extends sys.db.Object {
    public var id : SId;
    public var name : SString<32>;
    public var birthday : SDate;
    public var phoneNumber : SNull<SText>;
    // public var admin = false;
}