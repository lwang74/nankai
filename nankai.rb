#coding UTF-8
require 'rubygems'
require 'mechanize'
require 'fileutils'

class NankaiPage
	attr :valid_code
	def initialize p_name
		@p_name = p_name
		@agent = Mechanize.new
# pp Mechanize::AGENT_ALIASES

		@agent.user_agent_alias = 'Windows IE 6' 
		# agent.add_auth('http://www.baidu.com/', 'itc940167', 'naomi_94c167', nil, 'ITC')
		@agent.set_proxy('127.0.0.1', 3128)
	end

	def connect url
		@page = @agent.get(url)

		# pp @page 
		# @valid_code = @page.images_with(:src=>"/ValidateCode")[0]
		valid_img = "ValidateCode.jpg"
		FileUtils.rm_f(valid_img)
		@agent.get("http://222.30.32.10/ValidateCode").save(valid_img)

		form = @page.form_with(:name => "stdloginActionForm")
		form.field_with(:name => "usercode_text").value = "1411993"
		form.field_with(:name => "userpwd_text").value = "040620"
		puts "Input validate code:"
		form.field_with(:name => "checkcode_text").value = gets

		# results = @agent.submit form
		results = form.click_button()

		# pp results
		# pp results.body 
		# puts results.body.force_encoding('gbk').encode('utf-8')
		# pp results.frames.size

		# pp results.response
		# pp results.response['Content-Type']
		# pp results.header
		# pp results.code
		
		page2 = @agent.get("http://222.30.32.10/xsxk/sub_xsxk.jsp")
		# pp page2
		# puts page2.body.force_encoding('gbk').encode('utf-8')

		page3 = @agent.get("http://222.30.32.10/xsxk/selectMianInitAction.do")
		# pp page3
		# puts page3.body.force_encoding('gbk').encode('utf-8')

		# form3 = page3.form_with(:name => "swichXsxkActionForm")
		# want_code = "0091"
		# form3.field_with(:name => "xkxh1").value = want_code
		# form3.field_with(:name => "operation").value = 'xuanke'
		# page4 = form3.click_button(form3.button_with(:name => 'xuanke'))
		wants = [%W(0014 0041 0050 0091)]
		n=100
		while(n>0) do
			wants.each{|one|
				page3 = sel(page3, one)
			}

			codes = get_selected(page3)
			wants.flatten.each{|one|
				if codes.include?(one)
					puts "#{one} SUCCESS!!!!!!"
				else 
					print '.'
					# puts "#{one} FAIL!!!!!!"
				end
			}		
			sleep 30
			n-=1
		end
		pp codes
	rescue Mechanize::ResponseCodeError=>e
		puts e.message
	end

	def sel page, code
		form = page.form_with(:name => "swichXsxkActionForm")
		form.field_with(:name => "xkxh1").value = code[0]
		form.field_with(:name => "xkxh2").value = code[1] if code[1]
		form.field_with(:name => "xkxh3").value = code[2] if code[2]
		form.field_with(:name => "xkxh4").value = code[3] if code[3]
		form.field_with(:name => "operation").value = 'xuanke'
		page = form.click_button(form.button_with(:name => 'xuanke'))
	end

	def get_selected page
		all = []
		loop do
			form = page.form_with(:name => "swichXsxkActionForm")
			form.field_with(:name => "operation").value = 'coursepage'
			form.field_with(:name => "index").value = 'next'
			code = get_info(page)
			if all.size>=1 and code==all[all.size-1]
				break
			else
				all<<code
			end
			page = form.submit
		end
		all.flatten

		# form = page.form_with(:name => "swichXsxkActionForm")
		# form.field_with(:name => "operation").value = 'coursepage'
		# form.field_with(:name => "index").value = 'next'
		# puts '==========================================================='
		# pp get_info page
		# page = form.submit

		# form = page.form_with(:name => "swichXsxkActionForm")
		# form.field_with(:name => "operation").value = 'coursepage'
		# form.field_with(:name => "index").value = 'next'
		# puts '==========================================================='
		# pp get_info page
		# page = form.submit

		# puts '==========================================================='
		# pp get_info page
	end
	def get_info page
		codes = page.search('//table[2]/tr').map{|e|
			e.search('td[2]').map{|td|
				td.text
			}
			# puts '==========================================================='
			# page.search('//table[2]/tr').map{|e|
			# 	puts e.search('td').map{|td|
			# 		td.text
			# 	}.join('-')
			# }
		}
		codes.shift
		codes.flatten
	end
end

if __FILE__==$0
	url = 'http://222.30.32.10'
	# url = 'http://222.30.32.10/xsxk/studiedAction.do'

	nan_page = NankaiPage.new('nankai')
	nan_page.connect(url)
	
	# pp urls = my_page.links(//)
	# imgs = my_page.imgs(/^http:\/\/data\.5ikfc\.com\/coupons\/mdl\/2015\/mdl\-5ikfc\-/, urls)
	# my_page.downloal_imgs(imgs)


	# 课程 2311, (必修剩余名额不足)选课操作失败(或不在指定的选课年级)！
# 0014 0041 0050 0091
end


