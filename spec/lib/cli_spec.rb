require 'versioner/cli'

%w(branch tag).each do |version_object|
  describe "version" do

    let(:version_file) {
      "#{File.dirname(__FILE__)}/TEST_VERSION"
    }

    let(:related_version_files) {
      ["#{File.dirname(__FILE__)}/TEST_VERSION_2", "#{File.dirname(__FILE__)}/TEST_VERSION_3"]
    }

    let(:git_dir) {
      Dir.mktmpdir
    }

    before {
      File.open(version_file, 'w') { |f| f.write(" 1.2.0 ") }

      Dir.chdir(git_dir) {
        %x[git init]
        %x[touch somefile]
        %x[git add somefile]
        %x[git commit -m "init" .]
        %x[git #{version_object} version/1.2.32]
        %x[git #{version_object} version/1.2.33]
        %x[git #{version_object} version/1.2.34]
        %x[git #{version_object} origin/version/1.2.31]
        %x[git #{version_object} origin/version/1.2.32]
        %x[git #{version_object} origin/version/1.2.33]
        %x[git #{version_object} origin/version/1.2.34]
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

        Versioner::Cli::Root.start("#{action_example_group.full_description} -d #{git_dir} -f #{File.dirname(__FILE__)}/TEST_VERSION -o #{version_object} -r #{related_version_files.join(" ")}".split)
      }
    }

    describe "current" do

      describe "dev" do

        it { should eq("1.2.0\n") }

      end

      describe "release" do

        it { should eq("1.2.34\n") }


        describe "#bump over 9 -> 10" do
          before {
            Dir.chdir(git_dir) {
              %x[git #{version_object} origin/version/1.3.9]
              %x[git #{version_object} origin/version/1.3.10]
            }
          }

          it { should eq("1.3.10\n") }
        end
      end


    end

    describe "next" do

      describe "release" do

        it { should eq("1.2.35\n") }

      end

      describe "bump" do

        it "should bump version and make #{version_object}" do
          should include("Bumped version to 1.2.35\n")

          expect(Dir.chdir(git_dir) {
            %x[git #{version_object}]
          }).to include("version/1.2.35")

          expect(Dir.chdir(git_dir) {
            %x[git #{version_object}]
          }).to_not include("version/1.2.36")

          expect(File.read(version_file)).to eq("1.2.35")

          related_version_files.each { |related_file|
            expect(File.read(related_file)).to eq("1.2.35")
          }
        end

      end
    end


  end
end