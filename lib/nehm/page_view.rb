module Nehm
  module UI
    class PageView

      def initialize
        @choices = {}
        @inc_index = 1
        @items = []
      end

      def start
        yield self
        select
      end

      def newline
        @items << "\n"
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
        @header = string
      end

      def select
        UI.say @header

        @items.each do |item|
          UI.say item
        end

        UI.newline

        selected = UI.ask('Enter option'.yellow)
        block = @choices[selected]
        block.call

        UI.newline
      end

    end
  end
end
