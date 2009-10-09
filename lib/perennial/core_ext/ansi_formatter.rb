module Perennial
   class ANSIFormatter
    
    TAGS = {
      :bold          => 1,
      :italics       => 3,
      :underline     => 4,
      :inverse       => 7,
      :strikethrough => 9
    }
    
    COLOURS = {
      :black         => 30,
      :red           => 31,
      :green         => 32,
      :yellow        => 33,
      :blue          => 34,
      :magenta       => 35,
      :cyan          => 36,
      :white         => 37
    }
    
    BACKGROUND_COLOURS = {
      :bg_black      => 40,
      :bg_red        => 41,
      :bg_green      => 42,
      :bg_yellow     => 43,
      :bg_blue       => 44,
      :bg_magenta    => 45,
      :bg_cyan       => 46,
      :bg_white      => 47
    }
    
    
    UNDO_TAGS = {
      :all           => 0,
      :bold          => 22,
      :italics       => 23,
      :underline     => 24,
      :inverse       => 27,
      :strikethrough => 29,
      :colour        => 39,
      :bg_colour     => 49
    }
    
    MATCH_REGEXP = /\<f\:(.+)\>(.*)\<\/f\:\1>/
    ESCAPE_TAG   = /\<\/?f\:escape\>/
    ANSI_CODE    = /\033\[(?:\d+\;?)+m/
    
    cattr_accessor :formatted
    @@formatted = true
    
    def initialize(string)
      @string  = string
    end
    
    def to_s
      @@formatted ? to_formatted_s : to_normal_s
    end
    
    def to_formatted_s
      format_tags
    end
    
    def to_normal_s
      remove_tags
    end
    
    class << self
      
      def format(tag, text)
        tag = tag.to_s.gsub(/[\-\:]/, "_").to_sym
        "\033[#{lookup_tag(tag)}m#{text}\033[#{lookup_end_tag(tag)}m"
      end

      def lookup_tag(tag)
        TAGS[tag] || COLOURS[tag] || BACKGROUND_COLOURS[tag]
      end
      
      def lookup_end_tag(tag)
        UNDO_TAGS[lookup_tag_type(tag)] || UNDO_TAGS[:all]
      end
      
      def lookup_tag_type(tag)
        if COLOURS.has_key?(tag)
          tag = :colour
        elsif BACKGROUND_COLOURS.has_key?(tag)
          tag = :bg_colour
        end
        tag
      end
      
      def clean(text)
        text = text.gsub(ESCAPE_TAG, "") while text =~ ESCAPE_TAG
        text = text.gsub(ANSI_CODE,  "") while text =~ ANSI_CODE
        text
      end
      
      def process(string)
        new(string).to_s
      end
      
    end
    
    protected
    
    def format_tags(string = @string, tag_stack = nil, mapping = nil)
      tag_stack ||= []
      mapping   ||= Hash.new { |h,k| h[k] = [] }
      string.gsub(MATCH_REGEXP) do
        inner_text = $2
        tag = $1.to_s.gsub(/[\-\:]/, "_").to_sym
        type      = self.class.lookup_tag_type(tag)
        start_tag = self.class.lookup_tag(tag)
        end_tag   = UNDO_TAGS[type]
        if tag == :escape 
          inner_text
        elsif end_tag.present?
          mapping[type] << start_tag
          text = "\033[#{start_tag}m#{format_tags(inner_text, (tag_stack + [:type]), mapping)}\033[#{end_tag}m"
          mapping[type].pop
          text << "\033[#{mapping[type].join(";")}m"
        else
          format_tags(inner_text, tag_stack, mapping)
        end
      end
    end
    
    def remove_tags(string = @string)
      string.gsub(MATCH_REGEXP) { remove_tags($2) }
    end
    
  end
end

class String
  
  def to_ansi
    Perennial::ANSIFormatter.process(self)
  end
  
end