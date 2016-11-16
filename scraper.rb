require 'nokogiri'
require 'open-uri'
require 'pry'

SITEMAP_URL = "https://hiring.careerbuilder.com/sitemap-employer.xml"

def confirm_or_create_directories(filepath)
  # Everything but the last part of the URL will become a directory
  directories = filepath.split("/")[0..-2]

  directories.each do |dir_name|
    nested_dir_name = directories[0..directories.index(dir_name)].join("/")
    FileUtils.mkdir_p(nested_dir_name)
  end
end

def pull_assets
  puts "https://hiring.careerbuilder.com/application.css"
  `curl -XGET https://hiring.careerbuilder.com/application.css >> application.css`
  puts "https://hiring.careerbuilder.com/application.js"
  `curl -XGET https://hiring.careerbuilder.com/application.js >> application.js`
end

pull_assets
sitemap = Nokogiri::HTML(open(SITEMAP_URL))
sitemap.xpath("///loc").each do |node|
  url = node.content
  filepath = url.split("https://hiring.careerbuilder.com/")[1]

  confirm_or_create_directories(filepath) unless filepath.nil?
  filepath.nil? ? (filepath = "index") : nil
  puts url

  begin
    File.open("#{filepath}.html", 'w+') do |file|
      page = Nokogiri::HTML(open(url))
      file.write(page)
    end
  rescue OpenURI::HTTPError => e
    if e.message == '404 Not Found'
      puts "Error 404 - Page Not Found..."
    end
  end
end
