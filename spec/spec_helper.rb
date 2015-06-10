$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_propagation'
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", 
                                       :database => File.dirname(__FILE__) + "/active_propagation.sqlite3")
load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/models.rb'

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
