require "active_record/connection_adapters/mysql2_adapter"
require "db_annotator"
require "mysql2"

module ActiveRecord
  class Base
    class << self
      # Copied from activerecord-4.2.10/lib/active_record/connection_adapters/mysql2_adapter.rb
      # Replaced ConnectionAdapters::Mysql2Adapter with ConnectionAdapters::Mysql2AnnotatorAdapter
      # Cried a little bit into our keyboards.
      def mysql2_annotator_connection(config)
        config = config.symbolize_keys

        config[:username] = 'root' if config[:username].nil?

        if Mysql2::Client.const_defined? :FOUND_ROWS
          config[:flags] = Mysql2::Client::FOUND_ROWS
        end

        client = Mysql2::Client.new(config)
        options = [config[:host], config[:username], config[:password], config[:database], config[:port], config[:socket], 0]
        ConnectionAdapters::Mysql2AnnotatorAdapter.new(client, logger, options, config)
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
    class Mysql2AnnotatorAdapter < Mysql2Adapter
      ADAPTER_NAME = 'Mysql2'.freeze

      def annotation
        @annotation
      end

      def annotation=(value)
        return if value.to_json.include?("*/")
        @annotation = value
        @annotation_comment = nil
        annotation_comment
      end

      def execute(sql, name = nil)
        sql = annotation_comment + sql unless @annotation.nil?
        super
      end

      private

      def annotation_comment
        @annotation_comment ||= DbAnnotator::COMMENT_PREFIX + @annotation.to_json + DbAnnotator::COMMENT_SUFFIX
      end
    end
  end
end
