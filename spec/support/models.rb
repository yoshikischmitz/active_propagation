class Post < ActiveRecord::Base
  belongs_to :post
  has_many :posts, class_name: "Post"
  has_many :other_posts
end

class OtherPost < ActiveRecord::Base
  belongs_to :post
end
