module Gem
  class StreamUI
    def self.say_capture_buffer=(say_capture_buffer)
      @@say_capture_buffer = say_capture_buffer
    end

    def self.noninteractive_chooser=(noninteractive_chooser)
      @@noninteractive_chooser = noninteractive_chooser
    end
    
    def say(statement="")
      unless defined? @@say_capture_buffer and !@@say_capture_buffer.nil?
        @outs.puts statement
        return
      end
      @@say_capture_buffer << statement
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