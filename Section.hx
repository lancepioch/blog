import sys.db.Types;

class Section extends sys.db.Object {
    public var id : SId;
    public var title : SString<50>;
    public var weight : SInt = 0;

    public function getPosts() : List<Post> {
        return Post.manager.search($sectionId == id);
    }
}