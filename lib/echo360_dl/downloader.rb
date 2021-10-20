module Echo360DL
  class Downloader
    attr_accessor :url, :filename, :prefix, :response, :cookies

    def initialize(url, filename: nil, prefix: "", cookies: {})
      @url = url
      @prefix = prefix
      @filename = @prefix + (filename || @url[%r{[^/]+.m4s}]).gsub("m4s", "mp4")
      @cookies = cookies
      @response = nil
    end

    def download
      puts "download #{filename}"
      puts "skipping" and return if @response&.success?

      File.open(filename, "w") do |file|
        @response = HTTParty.get(url, cookies: cookies, stream_body: true) do |fragment|
          if [301, 302].include?(fragment.code)
            print "skip writing for redirect"
          elsif fragment.code == 200
            print "."
            file.write(fragment)
          else
            raise StandardError, "Non-success status code while streaming #{fragment.code}"
          end
        end
      end
      puts
      puts "Success: #{@response&.success?}"
      puts File.stat(filename).inspect
    end
  end
end
