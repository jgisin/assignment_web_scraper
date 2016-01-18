require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'pry-byebug'

class WebScraper
  attr_accessor :agent, :home_page, :search_query, :search_form

  def initialize
  # Instantiate a new Mechanize
    @agent = Mechanize.new
    @home_page = @agent.get('http://dice.com/')
    #binding.pry
    @search_form = @home_page.form_with(:action => "/jobs")
    @search_query = nil
    @search_result
  end


  def search(query, location)
    @search_form.fields[0].value = query
    @search_form.fields[1].value = location
    @search_query = @agent.submit(@search_form, @search_form.buttons[0])
  end

  def search_results
    @search_result = @search_query.search("//div[@class='serp-result-content']")
  end

  def get_company(result)
    result.search("//li[@class='employer']")[0].children[4].children[0].text
  end

  def iterate
    @search_result.each do |result|
      p get_company(result)
    end
  end


end

web = WebScraper.new
#binding.pry
web.search("web", "aurora")
#p web.search_results[0].search("//li[@class='employer']")[0].children[4].children[0].text
web.search_results
p web.iterate
