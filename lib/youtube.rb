require 'net/http'
require 'openssl'
require 'xmlsimple'
require_relative './multipart.rb'

#this is going to give you a warning every time but its an easy cheat around ssl ca issues.
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

module YouTube
  HOST = 'https://gdata.youtube.com/'
  APIVER = 2

  class Service
    
    
    def initialize(apikey = 'AI39si7O_YDdmFY6zHRqvsLfzitUNIWwqMaGX-b-_hQLXLBgv_PSJuGTSpXEocgRobUivYzZ9KXO-B_U_tJVs9D3vmGEzfnUfg')
      @key = apikey
    end

    #All we really do here is get a authenticated toke for the user.
    def connect(user)
      uri = URI('https://www.google.com/accounts/ClientLogin')
      post = Net::HTTP::Post.new uri.path
      post.set_form_data('Email' => user.name, 'Passwd' => user.password, 'service' => 'youtube', 'source' => 'devapp')
      response = nil
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        response = http.request post
        raise BadPasswordError, "Bad password for, #{user.name}." if response.body.start_with?('Error')

        user.token = response.body.to_s.slice(/Auth=(.*)/, 1)
      end

      puts user.token
      puts response
      return response
    end

    
    def upload(video, user)
      self.connect(user) unless user.token?
      uri = URI(HOST + 'feeds/api/users/default/uploads')
      post = Net::HTTP::Post.new uri.path
      post.body_stream, post.content_type = Multipart::Post.prepare_query("atom" => video.atom, "Video" => video.file)
      post.add_field('Slug', video.name)
      post.content_type = "multipart/related;"
      post.
      post.body video.atom
      post.
      _http_post(uri, post, user)
    end

    def comment (video, str, user)
      self.connect(user) unless user.token?
      uri = URI(HOST + 'feeds/api/videos/' + video.id.to_s + '/comments')
      post = Net::HTTP::Post.new uri.path
      post.content_type = 'application/atom+xml'
      post.body = Comment.formatString(str)
      _http_post(uri, post, user)
    end

    def search(term, index = 1, results = 10)
      res = _api_call('feeds/api/videos', {'q' => term,'start-index' => index,'max-results' => results})

      videos = Array.new()
      res['entry'].each { |entry| videos.push(Video.new(entry['group'][0]['videoid'][0], entry['title'][0],
                                                   entry['group'][0]['description'][0]['content'],
                                                   entry['author'][0]['name'][0],
                                                   Rating.new(entry['rating'][1]['numLikes'], entry['rating'][1]['numDislikes'])))}
      return videos
    end

    private

    def _api_call(method, args)
      uri = _uri(method, args)
      response = XmlSimple.xml_in(_http_get(uri))
    end

    def _http_get(uri)
      response = nil
       Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
         request = Net::HTTP::Get.new uri.request_uri
         request.add_field('X-GData-Key', "key=#{@key}")
         response = http.request request
       end
      response.body.to_s
    end

    def _uri(method, args)
      uri = URI "#{HOST}#{method}?#{URI.encode_www_form(args)}&v=#{APIVER}"
    end

    def _http_post(uri, post, user)
      post.add_field('Authorization', "GoogleLogin auth=#{user.token}")
      post.add_field('X-GData-Key', "key=#{@key}")
      post.add_field('GData-Version', '2')

      response = 0
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|

        response = http.request post
        puts response.body
        puts "\n\n\n"
        puts response
      end

      return response
    end

  end

  class User
    attr_reader :name
    attr_reader :password
    attr_accessor :token

    def initialize (name, password)
      @name = name
      @password = password
    end

    def comment (video, str)
      Service.new.comment(video, str, self)
    end

    def upload (video)
      Service.new.upload(video, self)
    end

    def token? ()
      @token != nil
    end
  end

  class Video
    attr_reader :name
    attr_reader :description
    attr_reader :uploader
    attr_reader :rating
    attr_reader :id
    attr_reader :file

    def initialize (id, name, description, uploader, rating)
      @id = id
      @name = name
      @description = description
      @uploader = uploader
      @rating = rating
      @file = nil
    end

    def getComment ()
      #todo add method to get comments for a video
    end
  end

  class Comment
    attr_reader :author
    attr_reader :text
    attr_reader :rating
    def initialize(author, text)
      @author = author
      @text = text
    end

    def self.formatString(str)
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:yt=\"http://gdata.youtube.com/schemas/2007\"><content>#{str}</content></entry>"
    end
  end

  class Rating
    attr_reader :up
    attr_reader :down

    def initialize(up, down)
      @up = up
      @down = down
    end
  end

  class Uploadable
    attr_reader :filename, :file
    attr_accessor :name, :description, :category, :keywords

    def initialize(file)
      raise IOError, "Cannot read #{file}" unless File.readable? file
      @file = file
      @filename = File.basename file
      @name = File.basename file
      @keywords = @name.split
      @category = 'experimental uploader'
      @description = "A video about #{@name}"
    end

    def atom()
      atom  = "<?xml version=\"1.0\"?><entry xmlns=\"http://www.w3.org/2005/Atom\" xmlns:media=\"http://search.yahoo.com/mrss/\" "
      atom << "xmlns:yt=\"http://gdata.youtube.com/schemas/2007\"> <media:group> <media:title type=\"plain\">#{@name}"
      atom << "</media:title> <media:description type=\"plain\">#{@description}</media:description>"
      atom << "<media:category scheme=\"http://gdata.youtube.com/schemas/2007/developertags.ca\">#{@category}</media:category>"
      atom << "<media:keywords>#{@keywords.join(', ')}</media:keywords></media:group></entry>"
    end
  end

  class BadPasswordError < StandardError

  end
end
