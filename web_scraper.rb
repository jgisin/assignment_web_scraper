require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'pry-byebug'

class WebScraper
  attr_accessor :agent, :home_page, :search_query, :search_form

  def initialize
  # Instantiate a new Mechanize
    @agent = Mechanize.new
    @agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @home_page = @agent.get('http://www.dice.com/')
    #binding.pry
    @search_form = @home_page.form_with(:action => "/jobs")
    @search_query = nil
    @company_result = nil
  end


  def search(query, location)
    @search_form.fields[0].value = query
    @search_form.fields[1].value = location
    @search_query = @agent.submit(@search_form, @search_form.buttons[0])
  end

  def search_results
    @search_result = @search_query.search("//div[@class='serp-result-content']")[0].search("//li[@class='employer']")
  end

  def get_company(result)
    result.children[4].children[0].text
  end

  def iterate
    @search_result.each do |result|
      #binding.pry
      p get_company(result)
    end
  end


end

web = WebScraper.new
web.search("web", "aurora")
#p web.search_results[0].search("//li[@class='employer']")[0].children[4].children[0].text
web.search_results

p web.iterate
