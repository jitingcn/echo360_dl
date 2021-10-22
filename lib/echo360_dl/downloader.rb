module Echo360DL
  class Downloader
    attr_accessor :url, :filename, :prefix, :responses, :cookies

    def initialize(url, filename: nil, prefix: "", cookies: {})
      @url = url
      @prefix = prefix
      @filename = @prefix + (filename || @url[%r{[^/]+.m4s}]).gsub("m4s", "mp4")
      @cookies = cookies
      @responses = nil
    end

    def download
      puts filename.to_s
      if @responses&.success?
        puts "skipping"
        return
      end

      progressbar = ProgressBar.create(starting_at: 0, total: nil, format: "Progress: %c |%B| %a", length: 80)
      File.open(filename, "w") do |file|
        @responses = HTTParty.get(url, cookies: cookies, stream_body: true) do |fragment|
          if [301, 302].include?(fragment.code)
            print "skip writing for redirect"
          elsif fragment.code == 200
            file.write(fragment)
            progressbar.increment
          else
            raise StandardError, "Non-success status code while streaming #{fragment.code}"
          end
        end
      end
      progressbar.finish
      puts
      puts "Success: #{@responses&.success?}"
      puts File.stat(filename).inspect
    end
  end
end
