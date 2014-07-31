require 'versioner/cli'

describe Versioner::GitVersionManager do

  describe "#initialize" do

    [
      {
        message: "no data",
        data: {}
      },
      {
        message: "empty object",
        data: {
          version_object: ""
        }
      },
      {
        message: "empty object",
        data: {
          version_object: nil
        }
      },
      {
        message: "bad object",
        data: {
          version_object: "blah"
        }
      }
    ].each do |test_data|

      it "should fail #{test_data[:message]}" do
        expect { described_class.new(test_data[:data]) }.to raise_error("Can only operate on git branches and tags")
      end

    end
  end
end