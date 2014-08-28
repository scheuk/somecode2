require 'versioner/util'
require 'versioner/simple_version_file_manager'

module Versioner
  class ChefVersionFileManager < SimpleVersionFileManager
    include Versioner::Util

    def initialize(options)
      super(options)

      @version_line_matcher = lambda { |line|
        line.start_with?('version')
      }
    end

    no_commands do
      def get_version
        version_line = version_file_lines(self.version_file).find(&@version_line_matcher)

        version_matcher = version_line.match(/version\s*\'(.*)\'/i) if version_line
        version = version_matcher.captures.first if version_matcher

        default(version, "0.0.0").strip
      end

      def _set_version(version_file, next_release_version)
        version_file_lines = version_file_lines(version_file)
        version_line_index = version_file_lines.find_index(&@version_line_matcher)

        if (version_line_index.nil?)
          version_file_lines << "version '#{next_release_version}'"
        else
          version_file_lines[version_line_index] = "version '#{next_release_version}'"
        end

        File.open(version_file, 'w') { |f|
          f.puts version_file_lines
        }

        puts self.extra_flags.include?("berkshelf")
        `berks install` if self.extra_flags.include?("berkshelf")
      end

      def version_file_lines(version_file)
        File.read(version_file).lines.map { |line|
          line.strip
        }
      end

      def extra_version_files
        if self.extra_flags.include?("berkshelf")
          ['Berksfile.lock']
        else
          []
        end
      end
    end
  end
end