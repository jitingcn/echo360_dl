require "ferrum"

module Echo360DL
  class Client
    attr_reader :browser, :context, :pages, :tasks

    def initialize(headless: true)
      @browser = Ferrum::Browser.new timeout: 60, browser_options: { "no-sandbox": nil }, headless: headless
      @context = browser.contexts.create
      @tasks = []
      @pages = []
    end

    def http_get(url)
      HTTParty.get url
    end

    def goto(url, page: browser)
      page.go_to "about:blank"
      page.network.clear :traffic
      puts "visiting #{url}"
      page.go_to url
      sleep 10
    end

    def traffic(page: browser)
      page.network.traffic
    end

    def media(page: browser)
      traffic(page: page)
        .filter { |ex| ex.request.url.match?(%r{.+/.*\.m4s\?.+}) && ex.request.method == "GET" }
        .map { |ex| ex.request.url }
        .uniq
    end

    def m3u8(page: browser)
      traffic(page: page)
        .filter { |ex| ex.request.url.match?(%r{.+/s\d+_\w+\.m3u8\?.+}) && ex.request.method == "GET" }
        .map { |ex| ex.request.url }
        .uniq
    end

    def transcript(page: browser)
      traffic(page: page)
        .filter { |ex| ex.request.url.include?("transcript") }
        .to_a&.first&.response&.url&.gsub("transcript", "transcript-file?format=vtt")
    end

    def m3u8_content(page: browser)
      m3u8(page: page).map { |link| HTTParty.get(link) }
    end

    def title(page: browser)
      page.title
    end

    def add_page(url)
      pages << url
    end

    def process
      pages.each_slice(4).map do |g|
        g.map do |url|
          Thread.new(context) do |c|
            page = c.create_page
            goto(url, page: page)
            add_task(page: page)
          end
        end.each(&:join)
      end
    end

    def add_task(page: browser)
      Dir.mkdir("download") unless File.directory?("download")
      count = media(page: page).each do |link|
        prefix = "download/#{"#{title(page: page)}-".gsub(%r{[/\\:*?"<>|]}, "_")}"
        tasks << Echo360DL::Downloader.new(link, prefix: prefix)
      end.size
      puts "add #{count} task for #{title(page: page)}"
      # if transcript
      #   @downloads << Echo360DL::Downloader.new(transcript, filename: "#{title}-transcript.vtt",
      #                                                       prefix: "download/", cookies: cookies)
      # end
    end

    def download_all
      tasks.each(&:process)
    end

    def make_aria2_list(filename: "aria2.txt")
      File.open(filename, "w") do |f|
        tasks.each do |task|
          f.write("#{task.url}\n  out=#{File.basename task.filename}\n")
        end
      end
      nil
    end

    def cookies(page: browser)
      page.cookies.all.values.map do |c|
        { "#{c.name}": c.value }
      end.map(&:merge!)[0]
    end
  end
end
