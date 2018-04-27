require "spec_helper"
require "pry"
require "db_annotator"
require "db_annotator/version"


describe DbAnnotator do
  def run_query(query = "SELECT 1")
    @connection.execute(query)
  end

  def get_annotation
    regex = Regexp.new(Regexp.escape(DbAnnotator::COMMENT_PREFIX) + "(.*)" + Regexp.escape(DbAnnotator::COMMENT_SUFFIX))
    regex.match(@sql)[1]
  end

  def check_for_annotation(annotation_string)
    expect(@sql).to include("#{DbAnnotator::COMMENT_PREFIX}#{annotation_string.to_json}#{DbAnnotator::COMMENT_SUFFIX}")
  end

  it "has a version number" do
    expect(DbAnnotator::VERSION).not_to be nil
  end

  it "rejects annotations containing */" do
    @connection.annotation = { x: "value1", "*/": "value2" }
    expect(@connection.annotation).to eq(nil)
  end

  context "when there is an annotation" do
    before do
      @connection.annotation = "foo"
    end

    it "annotates by jsonifying the annotation and embedding it in a SQL query comment" do
      run_query
      check_for_annotation("foo")
    end

    it "allows annotation to be changed during a session" do
      run_query
      @connection.annotation = "bar"
      run_query
      check_for_annotation("bar")
    end
  end

  context "when the annotation is an object" do
    let(:object_hash) { { :foo => "bar", "baz" => 123 } }
    before do
      @connection.annotation = object_hash
    end

    it "correctly serializes/deserializes the object" do
      run_query
      json_string = get_annotation
      object = JSON.parse(json_string)

      expect(object).to eq(object_hash.stringify_keys)
    end
  end

  context "when there is no annotation" do
    before do
      @connection.annotation = nil
    end

    it "does not annotate" do
      sql = "SELECT 1"
      run_query(sql)
      expect(@sql).to eq(sql)
    end
  end
end
