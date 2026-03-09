#!/usr/bin/env ruby

require "net/http"
require "uri"

DEFAULT_TIMEOUT = 10
MAX_REDIRECTS = 5

def normalize_url(url)
  return url if url.start_with?("http://", "https://")
  "https://#{url}"
end

def fetch_response(url, limit = MAX_REDIRECTS, chain = [])
  raise "Too many redirects" if limit <= 0

  uri = URI.parse(url)

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"
  http.open_timeout = DEFAULT_TIMEOUT
  http.read_timeout = DEFAULT_TIMEOUT

  request = Net::HTTP::Get.new(uri.request_uri.empty? ? "/" : uri.request_uri)
  request["User-Agent"] = "httpfinger/1.0"

  response = http.request(request)

  current = {
    url: url,
    code: response.code.to_i,
    message: response.message,
    location: response["location"]
  }

  chain << current

  case response
  when Net::HTTPRedirection
    location = response["location"]
    raise "Redirect without location header" unless location

    next_url = URI.join(url, location).to_s
    fetch_response(next_url, limit - 1, chain)
  else
    [response, chain]
  end
end

def extract_title(body)
  return nil if body.nil? || body.empty?

  match = body.match(/<title[^>]*>(.*?)<\/title>/im)
  return nil unless match

  title = match[1].gsub(/\s+/, " ").strip
  title.empty? ? nil : title
rescue
  nil
end

def print_redirect_chain(chain)
  return if chain.length <= 1

  puts "Redirect chain:"
  chain.each do |hop|
    line = "  #{hop[:code]} #{hop[:url]}"
    line += " -> #{hop[:location]}" if hop[:location]
    puts line
  end
  puts
end

def print_fingerprint(final_url, response, chain)
  body = response.body || ""
  title = extract_title(body)

  puts "URL: #{final_url}"
  puts "Status: #{response.code} #{response.message}"
  puts

  print_redirect_chain(chain)

  puts "Fingerprint:"
  puts "  Final URL      : #{final_url}"
  puts "  Server         : #{response['server'] || 'N/A'}"
  puts "  Content-Type   : #{response['content-type'] || 'N/A'}"
  puts "  Content-Length : #{response['content-length'] || body.bytesize}"
  puts "  Title          : #{title || 'N/A'}"
  puts "  Powered-By     : #{response['x-powered-by'] || 'N/A'}"
  puts "  CSP            : #{response['content-security-policy'] || 'N/A'}"
  puts "  HSTS           : #{response['strict-transport-security'] || 'N/A'}"
end

if ARGV.length != 1
  puts "Usage: ruby httpfinger.rb <url>"
  exit 1
end

begin
  input_url = normalize_url(ARGV[0])
  response, chain = fetch_response(input_url)
  final_url = chain.last[:url]
  print_fingerprint(final_url, response, chain)
rescue => e
  warn "Error: #{e.message}"
  exit 1
end
