# ActivePropagation

Provides an ActiveRecord extension for propagating changes amongst models. 

Propagations are ran as callbacks and can be propagated synchronously in background jobs, or synchronously within the callback lifecycle. Furthermore, the individual updates on each associated record can be ran in jobs of their own.

# Usage Example

Say you have a posts model with an optional `post_id` such that a Post can have many posts and also belong to a post:

```ruby
class Post < ActiveRecord::Base
  belongs_to :post
  has_many :sub_posts

  propagates_changes_to :sub_posts, only: [:title], on: [:update], async: true
end
```

This will register an `after_commit` callback that will fire a Sidekiq worker to set the titles of all of the sub_posts to be the same as their parent post.