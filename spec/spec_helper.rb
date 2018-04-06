$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "db_annotator"
require "rspec"
require "active_record"
require "active_record/connection_adapters/mysql2_annotator_adapter"
require "yaml"
DatabaseCredentials = YAML.load_file("spec/configuration.yml")

RSpec.configure do |config|
  def new_client(option_overrides = {})
    connection = ActiveRecord::Base.mysql2_annotator_connection(DatabaseCredentials["root"].merge(option_overrides))
    @connections ||= []
    @connections << connection
    return connection unless block_given?
    begin
      yield connection
    ensure
      connection.disconnect!
      @connections.delete(connection)
    end
  end

  config.before :each do
    @connection = new_client
    ActiveSupport::Notifications.subscribe "sql.active_record" do |_, _, _, _, data|
      @sql = data[:sql]
    end
  end

  config.after :each do
    @sql = nil
    @connections.each(&:disconnect!)
  end
end
