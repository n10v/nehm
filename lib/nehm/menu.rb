module Nehm
  module UI
    class Menu

      def initialize
        @choices = {}
        @inc_index = 1
        @items = []

        yield self
        select
      end

      def choice(index, desc, &block)
        # Visual index - index that you see in menu
        # Select index - index than can be selected
        # For example, if you use ':added' index
        # In menu you see 'A', but you can select it by number
        # You receive a warning though

        visual_index = select_index = index

        if index == :inc
          visual_index = select_index = @inc_index.to_s
          @inc_index += 1
        end

        if index == :added
          visual_index = 'A'.green
          select_index = @inc_index.to_s
          @inc_index += 1
        end

        @choices[select_index] = block
        @items << "#{visual_index} #{desc}"
      end

      def header=(string)
        @items << string
      end

      def newline
        @items << "\n"
      end

      def select
        newline
        choice('e', 'Exit'.red) { UI.term }

        # Output items
        @items.each do |item|
          UI.say item
        end

        UI.newline

        selected = UI.ask('Enter option'.yellow.freeze)
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
