module Nehm
  # ArgumentProcessor process arguments and return hash with options
  # Name of the method corresponds to the name of the command
  module ArgumentProcessor
    def self.get(args)
      options = {}
      options_names = %w(from playlist to)

      options_names.each do |option|
        if args.include? option
          index = args.index(option)
          value = args[index + 1]
          args.delete_at(index + 1)
          args.delete_at(index)

          options[option] = value
        end
      end
      options
    end
  end
end
