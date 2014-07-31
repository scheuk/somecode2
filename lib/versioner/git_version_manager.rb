module Versioner
  class GitVersionManager < Thor

    attr_accessor :version_prefix, :git_dir, :version_object

    def initialize(options)
      fail "Can only operate on git branches and tags" if options[:version_object].nil? || !['branch', 'tag'].include?(options[:version_object])

      self.version_prefix = options[:version_prefix]
      self.git_dir = options[:git_dir]
      self.version_object = options[:version_object]

      @pre_query_command = "git fetch 2>/dev/null" if options[:version_object] == 'tag'
      @remote_query_command = "git #{self.version_object} -r" if options[:version_object] == 'branch'
      @query_command = "git #{self.version_object}"
    end

    no_commands do
      def get_all_versions
        Dir.chdir(self.git_dir) {
          %x[#{@pre_query_command}] if @pre_query_command
          local_version_strings = %x[#{@query_command}].split
          remote_version_strings = []
          remote_version_strings = %x[#{@remote_query_command}].split if @remote_query_command
          (local_version_strings + remote_version_strings)
        }.select { |version_string|
          version_string.start_with?("#{self.version_prefix}version") || version_string.start_with?("origin/#{self.version_prefix}version")
        }.map { |version_string|
          version_string.split("/").last
        }
      end

      def create_version(next_release_version)
        Dir.chdir(self.git_dir) {
          %x[git #{self.version_object} #{self.version_prefix}version/#{next_release_version}]
        }
        say "Bumped #{self.version_prefix}version to #{next_release_version}"
      end

      def push_version(current_release_version)
        Dir.chdir(self.git_dir) {
          %x[git push origin #{self.version_prefix}version/#{current_release_version}]
        }
        say "Pushed #{self.version_prefix}version at #{current_release_version}"
      end
    end
  end
end