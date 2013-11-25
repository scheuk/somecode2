require 'thor'

class String
    def compare_as_version_string(other_string)

      self_parts = self.split(".")
      other_parts = other_string.split(".")

      if(self_parts.empty? ||  other_parts.empty?)
        return self_parts.size <=> other_parts.size
      end

      zipped = self_parts.first(other_parts.size).zip(other_parts)

      results = zipped.map { |self_item, other_item|
        self_item.to_i <=> other_item.to_i
      }

      result = results.detect { |result_item|
        result_item != 0
      } || 0

      if(result == 0 && other_parts.size != self_parts.size)
        return self_parts.size <=> other_parts.size
      end

      result
    end
end

module Versioner
  module Cli

    class BaseVersionStateTask < Thor
      include Thor::Actions
      class_option :version_file, aliases: %w[-f], :type => :string, :description => 'Version File', :default => './VERSION'
      class_option :git_dir, aliases: %w[-d], :type => :string, :description => 'Git Repo Directory', :default => '.'
      class_option :related_version_files, aliases: %w[-r], :type => :array, :description => 'Related Version Files', :default => []

      no_commands {
        def find_current_release_version
          Dir.chdir(options[:git_dir]) {
            local_branches = %x[git branch].split
            remote_branches = %x[git branch -r].split

            current_release_version = (local_branches + remote_branches).select { |branch|
              branch.start_with?("version") || branch.start_with?("origin/version")
            }.map { |branch|
              branch.split("/").last
            }.sort { |v1, v2|
              v1.compare_as_version_string(v2)
            }.last

            default(current_release_version, "0.0.0").strip
          }
        end

        def find_current_dev_version
          default(File.read(options[:version_file]), "0.0.0").strip
        end

        def find_next_release_version
          current_dev_version_parts = find_current_dev_version.split(".")
          current_release_version_parts = find_current_release_version.split(".")

          next_parts = (current_dev_version_parts[0..-2] == current_release_version_parts[0..-2]) ?
              current_release_version_parts :
              current_dev_version_parts

          next_release_version = (next_parts[0..-2] + [next_parts.last.to_i + 1]).join(".")
        end

        def default(value, default_value)
          (value.nil? || value.strip.empty?) ? default_value : value
        end
      }
    end

    class Current < BaseVersionStateTask

      desc 'dev', 'show current dev version'

      def dev
        say find_current_dev_version
      end

      desc 'release', 'show current release version'

      def release
        say find_current_release_version
      end

      desc 'push', 'push to the current released version to origin'

      def push
        current_release_version = find_current_release_version

        Dir.chdir(options[:git_dir]) {
          %x[git push origin version/#{current_release_version}]
        }

        say "Pushed version #{current_release_version}"
      end

    end

    class Next < BaseVersionStateTask

      class_option :push_to_origin, aliases: %w[-p], :type => :boolean, :description => 'Push to Origin after Bump'

      desc 'release', 'show next release version'

      def release
        say find_next_release_version
      end

      desc 'bump', 'bump to the next release version'

      def bump
        next_release_version = find_next_release_version

        Dir.chdir(options[:git_dir]) {
          %x[git branch version/#{next_release_version}]
          %x[git push origin version/#{next_release_version}] if options[:push_to_origin]
        }

        ([options[:version_file]] + options[:related_version_files]).each { |version_file|
          File.open(version_file, 'w') { |f| f.write(next_release_version) }
          say "Bumped #{version_file} to #{next_release_version}"
        }

        say "Bumped version to #{next_release_version}"
      end

    end

    class Version < Thor

      desc 'current', 'Tasks for current version state'
      subcommand 'current', Versioner::Cli::Current

      desc 'next', 'Tasks for next version state'
      subcommand 'next', Versioner::Cli::Next

    end

    class Root < Thor

      desc 'version', 'Tasks for version state'
      subcommand 'version', Versioner::Cli::Version

    end

  end
end