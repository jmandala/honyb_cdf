class FixedWidth
  class Parser
    def initialize(definition, file)
      @definition = definition
      @file = file
    end

    def parse
      @parsed = {}
      @content = read_file
      @content.each do |line|
        parse_line(line)
      end
      unless @content.empty?

      end
      @parsed
    end

    private

    def read_file
      @file.readlines.map(&:chomp)
    end

    def fill_content(section, line)
      add_to_section(section, line) if section.match(line)
    end


    def parse_line(line)
      @definition.sections.each do |section|
        if section.match(line)
          Rails.logger.debug "#{section.name}:#{line}"
          fill_content(section, line)
          break
        end
      end
    end


    def add_to_section(section, line)
      if section.singular
        @parsed[section.name] = section.parse(line)
      else
        @parsed[section.name] ||= []
        @parsed[section.name] << section.parse(line)
      end
    end
  end
end