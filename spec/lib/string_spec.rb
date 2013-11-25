require 'versioner/cli'

describe String do

  it "should compare by number not string" do

    expect(0 <=> 0).to eq(0)
    expect(1 <=> 0).to eq(1)
    expect(0 <=> 1).to eq(-1)

  end

  describe "#compareAsVersionString" do
    it "should compare by number not string" do

      expect("0.0.9".compare_as_version_string("0.0.10")).to eq(-1)
      expect("0.0.9.1".compare_as_version_string("0.0.10")).to eq(-1)
      expect("0.9.0".compare_as_version_string("0.10.0")).to eq(-1)
      expect("0.0.99".compare_as_version_string("0.0.100")).to eq(-1)
      expect("0.0.10".compare_as_version_string("0.0.9")).to eq(1)
      expect("0.10.0".compare_as_version_string("0.9.0")).to eq(1)
      expect("0.0.100".compare_as_version_string("0.0.99")).to eq(1)
      expect("0.0.0".compare_as_version_string("0.0.0")).to eq(0)
      expect("0.0.1".compare_as_version_string("0.0.0")).to eq(1)
      expect("0.0.0".compare_as_version_string("0.0.1")).to eq(-1)
      expect("0.0".compare_as_version_string("0.0.0")).to eq(-1)
      expect("0.0.0".compare_as_version_string("0.0")).to eq(1)
      expect("".compare_as_version_string("0")).to eq(-1)
      expect("0".compare_as_version_string("")).to eq(1)
      expect("".compare_as_version_string("")).to eq(0)

    end
  end
end