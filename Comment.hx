import sys.db.Types;

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