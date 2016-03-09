# worked with Eric

require "sinatra"
require "pg"
require_relative "./app/models/article"
require "pry"
require "erb"

set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end




get '/articles' do
  @all_articles = Article.all

  erb :index
end

get '/articles/new' do
  erb :article_form
end

post '/articles/new' do

  @new_submission_error = nil
  @new_article = Article.new(params)

  @title = @new_article.title
  @description = @new_article.description

  @new_article.save

  if @new_article.errors.empty?
    redirect '/articles'
  else
    @new_submission_error = true
    erb :article_form
  end
end
