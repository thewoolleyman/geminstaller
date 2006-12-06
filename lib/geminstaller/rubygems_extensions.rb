module Gem
  class StreamUI
    def self.noninteractive_chooser=(noninteractive_chooser)
      @@noninteractive_chooser = noninteractive_chooser
    end
    
    def choose_from_list(question, list)
      if @@noninteractive_chooser
        return @@noninteractive_chooser.choose(list)
      end
      @outs.puts question
      list.each_with_index do |item, index|
        @outs.puts " #{index+1}. #{item}"
      end
      @outs.print "> "
      @outs.flush
      result = @ins.gets.strip.to_i - 1
      return list[result], result
    end
  end
end