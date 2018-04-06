require 'active_record'
require 'mysql2'

module ActiveRecord
  class Base
    class << self
      # Copied from activerecord-4.2.10/lib/active_record/connection_adapters/mysql2_adapter.rb
      # Replaced ConnectionAdapters::Mysql2Adaptor with ConnectionAdapters::Mysql2AnnotatorAdaptor
      # Cried a little bit into our keyboards.
      def mysql2_annotator_connection(config)
        config = config.symbolize_keys

        config[:username] = 'root' if config[:username].nil?

        if Mysql2::Client.const_defined? :FOUND_ROWS
          config[:flags] = Mysql2::Client::FOUND_ROWS
        end

        client = Mysql2::Client.new(config)
        options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
        ConnectionAdapters::Mysql2AnnotatorAdaptor.new(client, logger, options, config)
      rescue Mysql2::Error => error
        if error.message.include?("Unknown database")
          raise ActiveRecord::NoDatabaseError.new(error.message, error)
        else
          raise
        end
      end
    end
  end

  module ConnectionAdapters
    class Mysql2AnnotatorAdaptor < Mysql2Adaptor
      ADAPTER_NAME = 'Mysql2Annotator'.freeze

      # The object that stores the annotations to include with each SQL query via a comment
      attr_reader :annotation

      def initialize(*)
        @annotation = nil
        super
      end

      # Returns the human-readable name of the adapter.
      def adapter_name
        ADAPTER_NAME
      end
    end
  end
end
