ActiveRecord::Schema.define do
  self.verbose = false

  create_table :posts, :force => true do |t|
    t.string :text
    t.references :post
    t.timestamps
  end

  create_table :other_posts, :force => true do |t|
    t.string :text
    t.references :post
    t.timestamps
  end
end
