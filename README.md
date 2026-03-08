# httpfinger

A simple Ruby CLI tool to fingerprint websites by fetching HTTP details such as status, redirects, headers, and page title.

## Features

- Fetches a URL and shows the final response
- Follows redirects
- Displays redirect chain
- Shows status code and message
- Extracts page title
- Displays useful headers like:
  - Server
  - Content-Type
  - Content-Length
  - X-Powered-By
  - Content-Security-Policy
  - Strict-Transport-Security

## Requirements

- Ruby
- Bundler

## Installation

Clone the repository:

```bash
git clone https://github.com/ExVoider/httpfinger.git
cd httpfinger
```

Install Bundler:

```
gem install bundler
```

Install dependencies:

```
bundle install
```

## Usage

```
ruby httpfinger.rb https://github.com
ruby httpfinger.rb github.com
```

## Example 

```
ruby httpfinger.rb https://github.com
```

*Example output:*

```
URL: https://github.com/
Status: 200 OK

Fingerprint:
  Final URL      : https://github.com/
  Server         : GitHub.com
  Content-Type   : text/html; charset=utf-8
  Content-Length : 12345
  Title          : GitHub · Build and ship software on a single, collaborative platform
  Powered-By     : N/A
  CSP            : default-src 'none'; ...
  HSTS           : max-age=31536000; includeSubdomains; preload
```
