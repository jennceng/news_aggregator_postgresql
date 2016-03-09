require_relative "../../server.rb"
class Article
  attr_reader :title, :description, :url, :errors

  def initialize (hash = {"title" => nil, "url" => nil, "description" => nil})
    @title = hash["title"]
    @url = hash["url"]
    @description = hash["description"]
    @errors = []
  end

  def empty_field?
    if @title.empty? || @description.empty? || @url.empty?
      @errors << "Please completely fill out form"
    end

  end

  def invalid_url?
    if !@url.empty? && !@url.include?("http")
      @errors << "Invalid URL"
    end
  end

  def url_duplicate?
    @all_urls = []
    db_connection do |conn|
      @all_urls = conn.exec_params("SELECT url FROM articles").to_a
    end

    @all_urls.each do |url|
      if url.has_value?(@url)
        @errors << "Article with same url already submitted"
      end
    end
  end

  def description_short?
    if !@description.empty? && @description.size < 20
      @errors << "Description must be at least 20 characters long"
    end
  end

  def valid?
    empty_field?
    invalid_url?
    url_duplicate?
    description_short?
    if @errors.empty?
      return true
    else
      return false
    end
  end

  def save
    if valid?
      db_connection do |conn|
        conn.exec_params("INSERT INTO articles (title, description, URL)
        VALUES ($1, $2, $3);",
        [@title, @description, @url])
      end
      return true
    end
    return false
  end

  def self.all
    @table_rows = []
    @all_articles = []
    db_connection do |conn|
      @table_rows = conn.exec("SELECT title, URL, description FROM articles").to_a
    end
    @table_rows.each do |article|
      @all_articles << Article.new(article)
    end
    return @all_articles
  end

end
