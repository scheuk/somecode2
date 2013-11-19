require 'versioner/cli'

describe "version" do

  let(:version_file) {
    "#{File.dirname(__FILE__)}/TEST_VERSION"
  }

  let(:git_dir) {
    Dir.mktmpdir
  }

  before {
    File.open(version_file, 'w') {|f| f.write(" 1.2.0 ") }

    Dir.chdir(git_dir){
      %x[git init]
      %x[touch somefile]
      %x[git add somefile]
      %x[git commit -m "init" .]
      %x[git branch version/1.2.32]
      %x[git branch version/1.2.33]
      %x[git branch version/1.2.34]
      %x[git branch origin/version/1.2.31]
      %x[git branch origin/version/1.2.32]
      %x[git branch origin/version/1.2.33]
      %x[git branch origin/version/1.2.34]
    }
  }

  after {
    File.delete(version_file)
    FileUtils.remove_entry git_dir
  }

  subject {
    capture(:stdout) {
      Versioner::Cli::Root.start("#{example.metadata[:example_group].full_description} -d #{git_dir} -f #{File.dirname(__FILE__)}/TEST_VERSION".split)
    }
  }

  describe "current" do

    describe "dev" do

      it { should eq("1.2.0\n")}

    end

    describe "release" do

      it { should eq("1.2.34\n")}

    end

  end

  describe "next" do

    describe "release" do

      it { should eq("1.2.35\n")}

    end

    describe "bump" do

      it "should bump version and make branch" do
        should eq("Bumped version to 1.2.35\n")

        expect(Dir.chdir(git_dir) {
          %x[git branch]
        }).to include("version/1.2.35")


      end

    end
  end


end