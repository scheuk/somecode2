describe String do

  subject { described_class }

  it { subject.should eq(String) }
  it { subject.should_not eq(Integer) }

  describe "#new" do

    subject(:instance) { described_class.new }

    it { should eq("") }

    describe "#include?" do

      let(:input) { "" }

      subject { instance.include?(input) }

      it { should eq(true) }

      context 'bad input' do

        let(:input) { "bad" }

        it { should eq(false) }

      end

    end

  end

end