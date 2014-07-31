module Versioner
  module Util
    def default(value, default_value)
      (value.nil? || value.strip.empty?) ? default_value : value
    end
  end
end