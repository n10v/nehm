module Nehm
  module UI
    class Menu

      def initialize
        @choices = {}
        @inc_index = 1
        @items = []
      end

      def start
        yield self
        select
      end

      def choice(index, desc, &block)
        if index == :inc
          index = @inc_index.to_s
          @inc_index += 1
        end

        @choices[index] = block
        @items << "#{index} #{desc}"
      end

      def header=(string)
        @items << string
      end

      def newline
        @items << "\n"
      end

      def select
        choice('e', 'Exit'.red) { raise Interrupt }

        # Output items
        @items.each do |item|
          UI.say item
        end

        UI.newline

        selected = UI.ask('Enter option'.yellow)
        call_selected_block(selected)

        UI.newline
      end

      def call_selected_block(selected)
        loop do
          if @choices.keys.include? selected
            block = @choices[selected]
            block.call
            break
          else
            selected = UI.ask "You must choose one of [#{@choices.keys.join(', ')}]"
          end
        end
      end

    end
  end
end
