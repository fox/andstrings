require "iconv"
require 'fileutils'

module Andstrings
  class LocalString
    def initialize string
      @string = string
      matches = StringsXml.xml.scan /name="([^"]+)">#{@string}<\/string>/
      if matches.size == 1
        @key = matches.first
        @in_strings_xml = true
      else
        @key = Iconv.iconv('ascii//translit', 'utf-8', @string).to_s.downcase.gsub(/[^ a-z0-9]/, '').gsub ' ', '_'
        @in_strings_xml = false
      end
    end

    def localisable?
      !(@string =~ /@string/) and @string =~ /[a-z]{2,}/
    end

    def key
      @key
    end

    def in_strings_xml?
      @in_strings_xml
    end
    
    def to_s
      @string
    end
  end

  class StringsXml
    def self.xml
      unless @strings_xml
        @num_new_strings = 0
        @path = "res/values/strings.xml"
        @strings_xml = File.read @path
      end
      @strings_xml
    end

    def self.put_string string
      @num_new_strings += 1
      xml.sub! "</resources>", "#{}\t<string name=\"#{string.key}\">#{string.to_s.gsub('"', '\\"')}</string>\n</resources>"
    end

    def self.save
      if @num_new_strings > 0
        Output.write @path, xml, @num_new_strings
      end
    end
  end

  class Output
    def self.outpath
      "andstrings"
    end

    def self.write path, content, log_num_changes
      FileUtils.mkdir_p("#{outpath}/#{File.dirname(path)}") 
      File.open("#{outpath}/#{path}", "w") { |f| f.write content }
      puts "#{outpath}/#{path} #{'+' * log_num_changes}"
    end
  end

end