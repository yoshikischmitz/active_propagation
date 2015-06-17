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

# Why?

Many Rails codebases rely heavily on callbacks to keep the application's state consistent. While changes can be propagated performantly and easily using `update_all` or `destroy_all`, if there are callbacks that need to be ran then this isn't possible. active_propagation calls `update` or `destroy` on each instantiated activerecord object so all callbacks are ran. By having an asynch option, even if you expect lots of dependent records and long running callbacks, each update and destroy, as well as their callbacks, are parallelized. 

Caveats:
- Currently the only supported job system is Sidekiq. The plan is to make this configurable for multiple backends(probably using ActiveJob).
- The callbacks are executed `after_commit`. This is to make sure it plays nicely with Sidekiq.
