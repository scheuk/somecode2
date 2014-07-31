require 'tmpdir'
require 'versioner/cli'

%w(branch tag).each do |version_object|
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
      File.open(version_file, 'w') { |f| f.write("") }

      Dir.chdir(git_dir) {
        %x[git init]
        %x[touch somefile]
        %x[git add somefile]
        %x[git commit -m "init" .]
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
        Versioner::Cli::Root.start("#{example.metadata[:example_group].full_description} -d #{git_dir} -f #{File.dirname(__FILE__)}/TEST_VERSION -o #{version_object} -r #{related_version_files.join(" ")}".split)
      }
    }

    describe "current" do

      describe "dev" do

        it { should eq("0.0.0\n") }

      end

      describe "release" do

        it { should eq("0.0.0\n") }

      end

    end

    describe "next" do

      describe "release" do

        it { should eq("0.0.1\n") }

      end


      describe "bump" do

        it "should bump version and make #{version_object}" do
          should include("Bumped version to 0.0.1\n")

          expect(Dir.chdir(git_dir) {
            %x[git #{version_object}]
          }).to include("version/0.0.1")


        end

        it "should bump version and make #{version_object}" do
          should include("Bumped version to 0.0.1\n")

          expect(Dir.chdir(git_dir) {
            %x[git #{version_object}]
          }).to include("version/0.0.1")

          expect(Dir.chdir(git_dir) {
            %x[git #{version_object}]
          }).to_not include("version/0.0.2")

          expect(File.read(version_file)).to eq("0.0.1")

          related_version_files.each { |related_file|
            expect(File.read(related_file)).to eq("0.0.1")
          }
        end

      end
    end

  end
end