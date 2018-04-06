require "spec_helper"

describe Db::Annotator do
  it "has a version number" do
    expect(Db::Annotator::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
