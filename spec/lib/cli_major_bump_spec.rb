require 'versioner/cli'

describe "version" do

  let(:version_file) {
    "#{File.dirname(__FILE__)}/TEST_VERSION"
  }

  let(:git_dir) {
    Dir.mktmpdir
  }


  let(:related_version_files) {
    ["#{File.dirname(__FILE__)}/TEST_VERSION_2", "#{File.dirname(__FILE__)}/TEST_VERSION_3"]
  }

  before {
    File.open(version_file, 'w') { |f| f.write(" 1.2.9 ") }

    Dir.chdir(git_dir) {
      %x[git init]
      %x[touch somefile]
      %x[git add somefile]
      %x[git commit -m "init" .]
      %x[git branch version/1.1.32]
      %x[git branch version/1.1.33]
      %x[git branch version/1.1.34]
      %x[git branch origin/version/1.1.31]
      %x[git branch origin/version/1.1.32]
      %x[git branch origin/version/1.1.33]
      %x[git branch origin/version/1.1.34]
    }
  }

  after {
    File.delete(version_file)

    related_version_files.each { |related_file|
      File.delete(related_file) if File.exist?(related_file)
    }

    FileUtils.remove_entry git_dir
  }

  subject {
    capture(:stdout) {
      action_example_group = findLowestAction(example.metadata[:example_group])
      Versioner::Cli::Root.start("#{action_example_group.full_description} -d #{git_dir} -f #{File.dirname(__FILE__)}/TEST_VERSION -r #{related_version_files.join(" ")}".split)
    }
  }

  describe "current" do

    describe "dev" do

      it { should eq("1.2.9\n") }

    end

    describe "release" do

      it { should eq("1.1.34\n") }

    end

  end

  describe "next" do

    describe "release" do

      it { should eq("1.2.10\n") }

    end


    describe "bump" do

      it "should bump version and make branch" do
        should include("Bumped version to 1.2.10\n")

        expect(File.read(version_file)).to eq("1.2.10")

        related_version_files.each { |related_file|
          expect(File.read(related_file)).to eq("1.2.10")
        }

        expect(Dir.chdir(git_dir) {
          %x[git branch]
        }).to include("version/1.2.10")

        expect(Dir.chdir(git_dir) {
          %x[git branch]
        }).to_not include("version/1.2.11")

      end

    end
  end

end