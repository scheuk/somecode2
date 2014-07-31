require 'versioner/chef_version_file_manager'

describe Versioner::ChefVersionFileManager do

  let(:version_file_name) { 'some_version_file' }
  let(:version_file_contents) { '
name             \'apache\'
maintainer       \'BBY Solutions, Inc.\'
maintainer_email \'Andrew.Painter@bestbuy.com\'
license          \'Apache 2.0\'
description      \'Installs/Configures apache\'
long_description IO.read(File.join(File.dirname(__FILE__), \'README.md\'))
version          \'1.2.3\'

supports \'centos\'
supports \'redhat\'
supports \'ubuntu\', \'14.04\'

  ' }

  let(:no_version_line_contents) { '
name             \'apache\'
maintainer       \'BBY Solutions, Inc.\'
maintainer_email \'Andrew.Painter@bestbuy.com\'
license          \'Apache 2.0\'
description      \'Installs/Configures apache\'
long_description IO.read(File.join(File.dirname(__FILE__), \'README.md\'))

supports \'centos\'
supports \'redhat\'
supports \'ubuntu\', \'14.04\'

  ' }

  let(:no_version_on_version_line_contents) { '
name             \'apache\'
maintainer       \'BBY Solutions, Inc.\'
maintainer_email \'Andrew.Painter@bestbuy.com\'
license          \'Apache 2.0\'
description      \'Installs/Configures apache\'
long_description IO.read(File.join(File.dirname(__FILE__), \'README.md\'))
version

supports \'centos\'
supports \'redhat\'
supports \'ubuntu\', \'14.04\'

  ' }

  let(:empty_version_on_version_line_contents) { '
name             \'apache\'
maintainer       \'BBY Solutions, Inc.\'
maintainer_email \'Andrew.Painter@bestbuy.com\'
license          \'Apache 2.0\'
description      \'Installs/Configures apache\'
long_description IO.read(File.join(File.dirname(__FILE__), \'README.md\'))
version          \'\'

supports \'centos\'
supports \'redhat\'
supports \'ubuntu\', \'14.04\'

  ' }

  let(:options) do
    {
      version_file: version_file_name
    }
  end

  subject(:instance) { described_class.new(options) }

  describe "#_set_version" do

    let(:mock_file) { double('mock version file') }

    let(:other_version_file) { 'other version file' }

    let(:expected_output_lines) { ['',
                                   'name             \'apache\'',
                                   'maintainer       \'BBY Solutions, Inc.\'',
                                   'maintainer_email \'Andrew.Painter@bestbuy.com\'',
                                   'license          \'Apache 2.0\'',
                                   'description      \'Installs/Configures apache\'',
                                   'long_description IO.read(File.join(File.dirname(__FILE__), \'README.md\'))',
                                   'version \'3.2.1\'',
                                   '',
                                   'supports \'centos\'',
                                   'supports \'redhat\'',
                                   'supports \'ubuntu\', \'14.04\'',
                                   '',
                                   ''] }

    before do
      File.should_receive(:read).with(other_version_file).and_return(version_file_contents)
      File.should_receive(:open).with(other_version_file, 'w') { |arg1, arg2, &arg3|
        arg3.call(mock_file)
      }
      mock_file.should_receive(:puts).with(expected_output_lines)

    end

    subject { instance._set_version(other_version_file, '3.2.1') }

    it { should be_nil }

    context 'no version file line' do
      let(:version_file_contents) { no_version_line_contents }
      let(:expected_output_lines) { ['',
                                     'name             \'apache\'',
                                     'maintainer       \'BBY Solutions, Inc.\'',
                                     'maintainer_email \'Andrew.Painter@bestbuy.com\'',
                                     'license          \'Apache 2.0\'',
                                     'description      \'Installs/Configures apache\'',
                                     'long_description IO.read(File.join(File.dirname(__FILE__), \'README.md\'))',
                                     '',
                                     'supports \'centos\'',
                                     'supports \'redhat\'',
                                     'supports \'ubuntu\', \'14.04\'',
                                     '',
                                     '',
                                     'version \'3.2.1\'']}

      it { should be_nil }
    end

    context 'no version on version line' do
      let(:version_file_contents) { no_version_on_version_line_contents }

      it { should be_nil }
    end

    context 'empty version on version line' do
      let(:version_file_contents) { empty_version_on_version_line_contents }

      it { should be_nil }
    end
  end

  describe "#get_version" do

    before do
      File.should_receive(:read).with(version_file_name).and_return(version_file_contents)
    end

    subject { instance.get_version }

    it { should eq('1.2.3') }

    context 'no version file line' do
      let(:version_file_contents) { no_version_line_contents }

      it { should eq('0.0.0') }

    end

    context 'no version on version line' do
      let(:version_file_contents) { no_version_on_version_line_contents }

      it { should eq('0.0.0') }

    end

    context 'empty version on version line' do
      let(:version_file_contents) { empty_version_on_version_line_contents }

      it { should eq('0.0.0') }

    end

  end
end