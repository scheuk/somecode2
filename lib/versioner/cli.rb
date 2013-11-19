require 'thor'

module Versioner
  module Cli

    class CurrentVersion < Thor
      include Thor::Actions

      desc 'dev', 'show current dev version'
      def dev
        say 'current dev'
      end

      desc 'release', 'show current release version'
      def release
        say 'current release'
      end

    end

    class NextVersion < Thor
      include Thor::Actions

      desc 'release', 'show next release version'
      def release
        say 'next release'
      end

    end

    class Version < Thor
      include Thor::Actions

      register Versioner::Cli::CurrentVersion, 'current', 'current', 'Tasks for current version state'
      register Versioner::Cli::NextVersion, 'next', 'next', 'Tasks for next version state'

      desc 'bump', 'bump to the next release version'
      def bump
        say 'bump release'
      end

    end

    class Root < Thor
      register Versioner::Cli::Version, 'version', 'version', 'Tasks for version state'
    end

  end
end