import sys.db.Types;

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