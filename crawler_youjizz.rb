#! /usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'nokogiri'
require 'net/http'
require 'open-uri'
require 'fileutils'
require 'mongo'
require 'mongo_mapper'

# Crawler for youjizz.com porn website
class CrawlerYoujizz
	@@URI_ROOT = "http://youjizz.com"
	@@XPATH_NEXT_PAGE = "//div[@id='pagination']/a[last()]"
	@@XPATH_MOVIE = "//span[@id='miniatura']"
	@@XPATH_MOVIE_URI = "span[@id='min']/a/@href"
	@@XPATH_MOVIE_TITLE = "span[@id='title1']"
	@@XPATH_MOVIE_THUMBNAILS = "//span[@id='miniatura']/span/img"
	@@LAST_PROCESSED_URI_PATH = ".last-url.txt"
	@@MONGODB_DBNAME = "atp"
	@@MONGODB_COLLECTION = "atp"

	def initialize
		@mongo = nil

		mongo_connect()
	end

	def mongo_connect
		begin
			@mongo = Mongo::Connection.new
		rescue Exception => e
			CrawlerYoujizz.log "Unable to connect to MongoDB, reason: '${e.to_s}'"
		end

		@mongo_db = @mongo.db(@@MONGODB_DBNAME)
		
		@mongo_coll = @mongo_db.collection(@@MONGODB_COLLECTION)
		
		# TODO: Make optional via command-line switch
		@mongo_coll.drop
		@mongo_coll = @mongo_db.collection(@@MONGODB_COLLECTION)

		CrawlerYoujizz.log "Connected to MongoDB"
	end

	# Log wrapper
	def self.log(msg)
		ts = Time.new.strftime("%Y/%m/%d %H:%M:%S")
		puts "[#{ts}] #{msg}"
	end

	# Fetches specified page and parses it with using of nokogiri parser
	def fetch(uri)
		CrawlerYoujizz.log "Fetching '#{uri}'"

		begin
			doc = Nokogiri::HTML(open(uri))
		rescue SystemExit, Interrupt
  			raise
		rescue Exception => e
			CrawlerYoujizz.log "Unable to fetch file, reason: '#{e.to_s}' "
		end
		return doc
	end

	def crawl_movie(uri)
		movie = {}
		
		doc = fetch(uri)
		doc_s = doc.to_s if doc
		url_start = doc_s.index('http://cdnb.videos.youjizz.com') if doc_s
		url_end = doc_s.index('"', url_start) if url_start
		movie['flv'] = doc_s.slice(url_start, url_end - url_start) if url_start && url_end

		return movie
	end

	# Extracts movies from parsed document
	def get_movies(doc)
		movies = []
		doc.xpath(@@XPATH_MOVIE).each do |node|
			movie = {}
			movie["type"] = :movie
			movie["uri"] = @@URI_ROOT + node.xpath(@@XPATH_MOVIE_URI).text
			movie["title"] = node.xpath(@@XPATH_MOVIE_TITLE).text
			movie["imgs"] = []
			node.xpath(@@XPATH_MOVIE_THUMBNAILS).each do |node_img|
				movie["imgs"] << node_img["data-original"]
			end

			# movie.merge!(crawl_movie(movie["uri"]))

			if(true || movie['flv'])
				begin
					unique = @mongo_coll.find({"uri" => Regexp.new(movie["uri"])}).count == 0
					@mongo_coll.insert(movie) if unique
				rescue Exception => e
					CrawlerYoujizz.log "Unable to insert document into MongoDB, reason: '#{e.to_s}'"
				end

				movies << movie
			else
				CrawlerYoujizz.log "Wrong movie - '#{movie['uri']}'"
			end
		end
		return movies
	end

	# Extracts link to next page
	def get_next_page(doc)
		doc.xpath(@@XPATH_NEXT_PAGE).each do |node|
			return node["href"]
		end
	end

	# Process youjizz.com page - extract movies, continue with next page
	def process(doc)
		movies = get_movies(doc)

		np = get_next_page(doc)
		@uri = nil
		@uri = @@URI_ROOT + np if np != nil
	end

	# Crawl youjizz.com page
	def crawl
		store_last_crawled_uri(@uri)
		process(fetch(@uri))
		puts "Documents: #{@mongo_coll.count}"
	end

	# Run app
	def run
		@uri = load_last_crawled_uri
		@uri = @@URI_ROOT + "/" if @uri.nil?
		
		# Non-recursive processing of all pages
		until @uri.nil? 
			crawl if @uri
		end
	end

private

	# Stores last processed youjizz.com URI
	def store_last_crawled_uri(uri)
		File.open(@@LAST_PROCESSED_URI_PATH, 'w') do |f|
			f.write("#{uri}\n")
		end
	end

	# Load last processed uri from file
	def load_last_crawled_uri
		return nil if File.exists?(@@LAST_PROCESSED_URI_PATH) == false
		File.open(@@LAST_PROCESSED_URI_PATH, 'r') do |f|
			return f.read.chomp
		end
	end

end

if __FILE__ == $0
	CrawlerYoujizz.new.run
end
