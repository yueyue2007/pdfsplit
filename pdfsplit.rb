#!/usr/bin/env ruby
require 'tempfile'
require 'open3'

def split_every_pages(pdf_file)	
	commstr = "pdfseparate #{pdf_file} #{File.basename(ARGV[1],".pdf")}-%d.pdf "
	#puts commstr
	unless system commstr
		puts "pdfseparate failed."
		exit
	end
end

def clear_every_page(pdf_file)
	commstr = "rm #{File.basename(ARGV[1],".pdf")}-*.pdf"
	#puts commstr
	system commstr
end

def pdf_unite(page_array,outfile) #page_array
	if page_array[0].to_i >= page_array[1].to_i 
		puts "begin page cannot greater than end page"
		exit
	end
	commstr = "pdfunite "
	from = page_array[0]
	to = page_array[1]
	from.upto(to) do |i|
		commstr << " #{page_array[2]}-#{i}.pdf"
	end
	commstr << " #{outfile}"
	#puts commstr
	system(commstr)
end

if $0 == __FILE__
	unless (ARGV.length == 4)||(ARGV.length == 2)
		puts "usage:pdfsplit aa.txt bcd.pdf [-amend 5]"
		exit
	end
	
	unless File.exist?(ARGV[0])
		puts "#{ARGV[0]} does not exist,please check the arguments."
		exit
	end
	unless File.exist?(ARGV[1])
		puts "#{ARGV[1]} does not exist,please check the arguments."
		exit
	end

	pages = []  # save the page index pf every pdf files
	File.open(ARGV[0]).readlines.each  do |line|
		#p line.chomp
		pages.push line.split(" ") unless line.chomp == ""
	end
	pages.each do |page|
		page[0] = page[0].to_i
		page[1] = page[1].to_i
	end
	#p pages
	#p ARGV[3]
	if ARGV[3] 
		pages.each do |page|
			page[0] = page[0] - ARGV[3].to_i
			page[1] = page[1] - ARGV[3].to_i			
		end
	end
	p pages

	#split the pdf into every page 
	split_every_pages(ARGV[1])

	1.upto pages.length do |index|
		pages[index-1][2] = File.basename(ARGV[1],".*")
		#p pages[index-1]
		outfile = "#{File.basename(ARGV[1],".*")}_#{index}.pdf"
		#p outfile
		pdf_unite(pages[index-1],outfile)

	end
	#clear the tmp files
	clear_every_page(ARGV[1])
	
end