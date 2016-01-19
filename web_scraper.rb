require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'pry-byebug'
require 'csv'

Job = Struct.new(:title, :company, :job_id, :company_id, :location, :link, :date)
class WebScraper
  attr_accessor :job_list, :agent, :search_link, :home_page, :search_query, :search_form

  def initialize
  # Instantiate a new Mechanize
    @agent = Mechanize.new
    @home_page = @agent.get('http://www.dice.com/')
    @search_link = nil
    @search_form = @home_page.form_with(:action => "/jobs")
    @search_query = nil
    unless search_query.nil?
      @job_click = @search_query.search('div.serp-result-content')[0]
    end
    @job_list = []
  end


  def search(query, location)
    @search_form.fields[0].value = query
    @search_form.fields[1].value = location
    @search_query = @agent.submit(@search_form, @search_form.buttons[0])
  end

  def job_link(num)
    @search_link = @search_query.search('div.serp-result-content')[num].children[1].children[1].attributes["href"].value
    @search_objects = @agent.get(@search_query.search('div.serp-result-content')[num].children[1].children[1].attributes["href"].value)
  end

  def job_name
    @search_object.search('h1.jobTitle').text
  end

  def employer
    begin
      @search_object.search('li.employer').children[1].text
    rescue
      "n/a"
    end
  end

  def get_id
    id_array = []
    begin
      id_array << @search_object.search('div.company-header-info').children[5].children[1].text
      id_array << @search_object.search('div.company-header-info').children[3].children[1].text
    rescue
      id_array << @search_object.search('div.company-header-info').children[3].children[1].text
      id_array << @search_object.search('div.company-header-info').children[1].children[1].text
    end
  end

  def company_id
    @search_object.search('div.company-header-info').children[3].children[1].text
  end

  def location
    @search_object.search('li.location').text
  end

  def date
    @search_object.search('li.posted hidden-xs').text
  end

  def iterate
    @search_object = @agent.get(job_link(0))
    30.times do |num|
      current_job = Job.new(job_name, employer, get_id[0], get_id[1], location, @search_link, convert_time(date))
      @search_object = job_link(num)
      @job_list << current_job
    end
  end

  def to_csv
    CSV.open('csv_file.csv', 'a') do |csv|
      @job_list.each do |job|
        csv << [job.title, job.company, job.company_id, job.job_id, job.location, job.link, job.date]
      end
      csv
    end
  end

  def convert_time(date_string)
    number = date_string.split(' ')[1].to_i
    multiplier = date_string.split(' ')[2]
    case multiplier
    when "hours"
      time = Time.new - (number * 3600)
    when "days"
      time = Time.new - (number * 86400)
    when "weeks"
      time = Time.new - (number * 604800)
    when "months"
      time = "Many Months"
    else
      time = "I don't know"
    end
    time
  end


end

web = WebScraper.new
web.search("web", "new york")

web.iterate
print web.job_list
web.to_csv

# #Job Name
# web.search_link = web.agent.get(web.job_link(5))
# p web.search_link.search('h1.jobTitle').text

#Employer
# web.search_link = web.agent.get(web.job_link(4))
# p web.search_link.search('li.employer').children[1].text

# #Location
# web.search_link = web.agent.get(web.job_link(1))
# p web.search_link.search("//li[@class='location']").text

# #Posted date
# web.search_link = web.agent.get(web.job_link(1))
# p web.search_link.search("//li[@class='posted hidden-xs']").text

#Company ID
# web.search_link = web.agent.get(web.job_link(5))
# p web.search_link.search("//div[@class='company-header-info']").children[1].text.strip

#Job ID
# web.search_link = web.agent.get(web.job_link(5))
# p web.search_link.search("//div[@class='company-header-info']").children[5].children[1]
