class FixedWidth
  class Parser
    def initialize(definition, file)
      @definition = definition
      @file = file
    end

    def parse
      @parsed = {}
      @content = read_file
      @content.each_with_index do |line, i|
        parse_line(line, i)
      end
      unless @content.empty?

      end
      @parsed
    end

    private

    def read_file
      @file.readlines.map(&:chomp)
    end

    def fill_content(section, line, line_number)
      add_to_section(section, line, line_number) if section.match(line)
    end


    def parse_line(line, line_number)
      @definition.sections.each do |section|
        if section.match(line)
          fill_content(section, line, line_number)
          break
        end
      end
    end


    def add_to_section(section, line, line_number)
      if section.singular
        @parsed[section.name] = section.parse(line, line_number)
      else
        @parsed[section.name] ||= []
        @parsed[section.name] << section.parse(line, line_number)
      end
    end
  end
end