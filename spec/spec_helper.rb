require 'rspec'
require 'yarjuf'

RSpec.configure do |config|
  # config.color_enabled = true
  config.formatter = 'documentation'

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def findLowestAction(current_example_group)
    (current_example_group.nil? || !current_example_group[:description].start_with?("#")) ?
        current_example_group :
        findLowestAction(current_example_group[:example_group])
  end
end
