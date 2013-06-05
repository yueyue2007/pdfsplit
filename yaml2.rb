#!/usr/bin/env ruby
#coding: UTF-8

require 'yaml'
require 'builder'

def split_every_pages(pdf_file) 
  commstr = "pdfseparate #{pdf_file}  #{File.dirname(pdf_file)+"/"+File.basename(pdf_file,".pdf")}-%d.pdf "
  puts commstr
  unless system commstr
    puts "pdfseparate failed."
    exit
  end
end

def clear_every_pages(pdf_file)
  commstr = "rm #{File.dirname(pdf_file)+"/"+File.basename(pdf_file,".pdf")}-*.pdf"
  puts commstr
  system commstr
end

# 
def pdf_unite(pdf_file,page_array,outfile) #page_array
  if page_array[0].to_i >= page_array[1].to_i 
    puts "begin page cannot greater than end page"
    exit
  end
  commstr = "pdfunite "
  from = page_array[0]
  to = page_array[1]
  base = File.dirname(pdf_file)+"/"+File.basename(pdf_file,".pdf")
  #puts base
  from.upto(to) do |i|
    commstr << " #{base}-#{i}.pdf" if File.exist?("#{base}-#{i}.pdf")
  end
  commstr << " #{File.dirname(pdf_file)}"+"/"+"#{outfile}"
  #puts commstr
  if commstr.split(" ").length < 3
    puts "   >>>>>  commstr failed"
    puts "   >>>>>" + "  " +commstr
    #exit
  else
    system(commstr)
  end
end


#1. 检查参数及配置文件是否存在？
usage  = '''
	issue  config.yaml
	'''

if !(ARGV.length == 1)
  puts usage
  exit;
end

if !File.exist?(ARGV[0])
  puts "config file does not exist"
  exit
end
#2 导入配置文件，分析其参数是否正确？
begin
  tree = YAML.load_file(ARGV[0])
rescue Exception => e
  puts "config file has errors: #{e}"
  #exit
end




tmpdir  =  File.dirname(tree['filename'])
basename = File.basename(tree['filename'],".*")
#tmpdir += "/tmpdir"
p tmpdir
p basename

if not File.exist?(tree['filename'].strip())
  puts "pdf file does not exist!"
  exit
end

pages = []

split_every_pages(tree['filename'].strip())



puts ""
puts "   以下是要导入的刊期的详细信息："
puts "   ----"
puts "   pdf文件路径: #{tree['filename']}"
puts "   刊期标题： #{tree['title']}"
puts "   卷：#{tree['volume']}"
puts "   编号：#{tree['number']}"
puts "   年份：#{tree['year']}"
puts "   pdf文件页码修正：#{tree['amend']} "
puts "  "

tree['sections'].each do |section|
  puts "      section:#{section['title']}; abbrev:#{section['abbrev']};articles:#{section['articles'].length}"
  puts "      ========================================================="
  puts ""
  section['articles'].each do |article|
    article['title'] = article['title'].strip()
    puts "         title:#{article['title']}"
    puts "         author:#{article['author_CN']}"
    puts "         author:#{article['author_EN']}"
    puts "         abstract:#{article['abstract']}"    
    puts "         pages:#{article['pages']}"
    article[:index] = article['pages'].split("-")
    if tree['amend'] != "0"
      amend = tree['amend'].to_i
      article[:index][0] = article[:index][0].to_i + amend
      article[:index][1] = article[:index][1].to_i + amend
    end
    #puts article[:index]
    article[:filename] = "#{article['title']}"+".pdf"
    #puts article[:filename]
    pdf_unite(tree['filename'],article[:index],article[:filename])
    article[:filename] = File.dirname(tree['filename'])+"/"+article[:filename]
    puts "         "+"file:"+article[:filename]
    puts "         -----------------------------"
    puts ""
  end
end



clear_every_pages(tree['filename'])



#4  生成XML文件

builder = Builder::XmlMarkup.new
builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
builder.declare! :DOCTYPE,:issues,:PUBLIC,"-//PKP//OJS Articles and Issues XML//EN","http://pkp.sfu.ca/ojs/dtds/2.4/native.dtd"
xml = builder.issues do |is|
  is.issue(:published=>"true",:identification=>"title",:current=>"false") do |issue|
    issue.title("#{tree['title']}",:locale=>"zh_CN")
    issue.access_date("2013-02-01")
    issue.volume("#{tree['volume']}")
    issue.number("#{tree['number']}")
    issue.year("#{tree['year']}")
    tree['sections'].each do |section_yaml|
      issue.section do |section_xml|
        section_xml.title("#{section_yaml['title']}",:locale=>"zh_CN")
        section_xml.abbrev("#{section_yaml['abbrev']}",:locale=>"zh_CN")
        section_yaml['articles'].each do |article_yaml|
          section_xml.article(:locale=>"zh_CN") do |article_xml|
            article_xml.title("#{article_yaml['title']}",:locale=>"zh_CN")
            article_xml.abstract("#{article_yaml['abstract']}",:locale=>"zh_CN")
            article_xml.author(:primary_contact=>"true") do |author|
              author.firstname("#{article_yaml['author_CN']}")
              author.lastname("#{article_yaml['author_EN']}")
              author.email("#{article_yaml['email']}")
            end
            article_xml.date_published("")
            article_xml.galley(:locale=>"zh_CN") do |galley|
              galley.label("PDF")
              galley.file  do |file|
                file.href(:src=>"#{article_yaml[:filename]}",:mime_types=>"application/pdf")
              end
            end
          end
        end
      end
    end
  end
end



File.open("comm.xml","w") {|f| f<<xml}


# 调用php，导入刊期和文章

# delete all pdf files of every article








