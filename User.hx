import sys.db.Types;

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