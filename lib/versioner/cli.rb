require 'thor'
require 'versioner/git_version_manager'
require 'versioner/util'

class String
  def compare_as_version_string(other_string)

    self_parts = self.split(".")
    other_parts = other_string.split(".")

    if (self_parts.empty? || other_parts.empty?)
      return self_parts.size <=> other_parts.size
    end

    zipped = self_parts.first(other_parts.size).zip(other_parts)

    results = zipped.map { |self_item, other_item|
      self_item.to_i <=> other_item.to_i
    }

    result = results.detect { |result_item|
      result_item != 0
    } || 0

    if (result == 0 && other_parts.size != self_parts.size)
      return self_parts.size <=> other_parts.size
    end

    result
  end
end

module Versioner
  module Cli

    class BaseVersionStateTask < Thor
      include Thor::Actions
      include Versioner::Util

      class_option :version_file, aliases: %w[-f], :type => :string, :description => 'Version File', :default => './VERSION'
      class_option :git_dir, aliases: %w[-d], :type => :string, :description => 'Git Repo Directory', :default => '.'
      class_option :related_version_files, aliases: %w[-r], :type => :array, :description => 'Related Version Files', :default => []
      class_option :version_prefix, aliases: %w[-v], :type => :string, :description => 'Prefix for version', :default => ""
      class_option :version_object, aliases: %w[-o], :type => :string, :description => 'Object for version', :default => "branch"
      class_option :version_file_manager_type, aliases: %w[-m], :type => :string, :description => 'Version File Manager Type (default simple)', :default => "simple"

      attr_accessor :scm_version_manager, :version_file_manager

      def initialize(*args)
        super
        self.scm_version_manager = Versioner::GitVersionManager.new(options)

        require "versioner/#{options[:version_file_manager_type]}_version_file_manager"

        self.version_file_manager = Versioner.const_get("#{options[:version_file_manager_type].capitalize}VersionFileManager").new(options)
      end

      no_commands {

        def find_current_release_version
          local_and_remote_branches = scm_version_manager.get_all_versions

          current_release_version = local_and_remote_branches.sort { |v1, v2|
            v1.compare_as_version_string(v2)
          }.last

          default(current_release_version, "0.0.0").strip
        end

        def find_current_dev_version
          self.version_file_manager.get_version
        end

        def find_next_release_version
          current_dev_version_parts = find_current_dev_version.split(".")
          current_release_version_parts = find_current_release_version.split(".")

          next_parts = (current_dev_version_parts[0..-2] == current_release_version_parts[0..-2]) ?
            current_release_version_parts :
            current_dev_version_parts

          (next_parts[0..-2] + [next_parts.last.to_i + 1]).join(".")
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
        self.scm_version_manager.push_version(find_current_release_version)
      end

    end

    class Next < BaseVersionStateTask

      class_option :push_to_origin, aliases: %w[-p], :type => :boolean, :description => 'Push to Origin after Bump'
      class_option :commit_version_files, aliases: %w[-c], :type => :boolean, :description => 'Commit Version files after Bump'

      desc 'release', 'show next release version'

      def release
        say find_next_release_version
      end

      desc 'bump', 'bump to the next release version'

      def bump
        next_release_version = find_next_release_version

        self.version_file_manager.set_version(next_release_version)

        if (options[:commit_version_files])
          Dir.chdir(options[:git_dir]) {
            self.version_file_manager.all_version_files.each { |version_file|
              %x[git add #{version_file}]
            }

            %x[git commit -m "Versioner bump version to #{next_release_version}"]
          }
        end

        self.scm_version_manager.create_version(next_release_version)

        if options[:push_to_origin]
          self.scm_version_manager.push_version(next_release_version)
        end

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