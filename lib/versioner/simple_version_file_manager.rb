require 'thor'
require 'versioner/util'

module Versioner
  class SimpleVersionFileManager < Thor
    include Versioner::Util

    attr_accessor :version_file, :related_version_files, :extra_flags

    def initialize(options)
      self.version_file = options[:version_file]
      self.related_version_files = options[:related_version_files]
      self.extra_flags = options[:extra_flags]
    end

    no_commands do
      def get_version
        default(File.read(self.version_file), "0.0.0").strip
      end

      def set_version(next_release_version)
        all_version_files.each { |version_file|
          _set_version(version_file, next_release_version)
          say "Bumped #{version_file} to #{next_release_version}"
        }
      end

      def _set_version(version_file, next_release_version)
        File.open(version_file, 'w') { |f| f.write(next_release_version) }
      end

      def all_version_files
        ([self.version_file] + self.related_version_files)
      end
    end
  end
end