require "ferrum"

module Echo360DL
  class Client
    attr_reader :browser, :tasks

    def initialize(headless: true)
      @browser = Ferrum::Browser.new timeout: 60, headless: headless
      @tasks = []
    end

    def http_get(url)
      HTTParty.get url
    end

    def goto(url)
      puts "visiting #{url}"
      browser.go_to url
      sleep 1
      browser.at_css("div[data-test-component='MediaInfoOverlay']").click
      sleep 1
    end

    def traffic
      browser.network.traffic
    end

    def media
      traffic.filter { |ex| ex.request.url.match?(%r{.+/.*\.m4s\?.+}) && ex.request.method == "GET" }
             .map { |ex| ex.request.url }
             .uniq
    end

    def m3u8
      traffic.filter { |ex| ex.request.url.match?(%r{.+/s\d+_\w+\.m3u8\?.+}) && ex.request.method == "GET" }
             .map { |ex| ex.request.url }
             .uniq
    end

    def transcript
      traffic.filter { |ex| ex.request.url.include?("transcript") }
             .to_a&.first&.response&.url&.gsub("transcript", "transcript-file?format=vtt")
    end

    def m3u8_content
      m3u8.map { |link| HTTParty.get(link) }
    end

    def title
      browser.title
    end

    def add_task
      puts "add task for #{title}"
      Dir.mkdir("download") unless File.directory?("download")
      media.each do |link|
        tasks << Echo360DL::Downloader.new(link, prefix: "download/#{"#{title}-".gsub(%r{[/\\:*?"<>|]}, "_")}")
      end
      # if transcript
      #   @downloads << Echo360DL::Downloader.new(transcript, filename: "#{title}-transcript.vtt",
      #                                                       prefix: "download/", cookies: cookies)
      # end
    end

    def download_all
      tasks.each(&:download)
    end

    def make_aria2_list(filename: "aria2.txt")
      File.open(filename, "w") do |f|
        tasks.each do |task|
          f.write("#{task.url}\n  out=#{File.basename task.filename}\n")
        end
      end
      nil
    end

    def cookies
      browser.cookies.all.values.map do |c|
        { "#{c.name}": c.value }
      end.map(&:merge!)[0]
    end
  end
end
