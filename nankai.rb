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
		# @agent.set_proxy('127.0.0.1', 3128)
	end

	def connect url
		@page = @agent.get(url)

		# pp @page 
		# @valid_code = @page.images_with(:src=>"/ValidateCode")[0]
		save_img "http://222.30.32.10/ValidateCode", "ValidateCode.jpg"

		form = @page.form_with(:name => "stdloginActionForm")
		form.field_with(:name => "usercode_text").value = "1411993"
		form.field_with(:name => "userpwd_text").value = "040620"
		print "Input validate code:"
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
		# wants = [%W(0014 0041 0050 0091)]
		# n=10000
		# while(n>0) do
			# wants.each{|one|
			# 	page3 = sel(page3, one)
			# }

			# codes = get_selected(page3)
			# wants.flatten.each{|one|
			# 	if codes.include?(one)
			# 		puts "#{one} SUCCESS!!!!!!"
			# 	else 
			# 		# print '.'
			# 		# puts "#{one} FAIL!!!!!!"
			# 	end
			# }

			page3 = get_course(page3, "924", 'shengyuwai', '限选剩余名额')
			codes = get_selected(page3)
			puts codes.map{|code|
				# p code
				code #if /校本部/=~ code
			}.compact

			page3 = get_course(page3, "909", 'shengyunei', '计划内剩余名额')
			codes = get_selected(page3)
			puts codes.map{|code|
				# p code
				code #if /校本部/=~ code
			}.compact
		# 	print '.'		
		# 	sleep 30
		# 	n-=1
		# end
		# pp codes
	rescue Mechanize::ResponseCodeError=>e
		puts e.message
	end

	def get_course page, sel_code, op, btn
		form = page.form_with(:name => "swichXsxkActionForm")
		img = page.image_with(:alt=>'无验证码图片')
		save_img img.src, "second.jpg"
		print 'Input second code:'
		second_code = gets
		form.field_with(:name => "code").value = second_code
		
		form.field_with(:name => "operation").value = op
		form['departIncode'] = sel_code
		page = form.click_button(form.button_with(:value => btn))

		# form.field_with(:name => "operation").value = 'shengyuwai'
		# form['departIncode'] = "924"
		# page = form.click_button(form.button_with(:value => '限选剩余名额'))
		
		# form.field_with(:name => "operation").value = 'shengyunei'
		# form['departIncode'] = "909" 
		# page = form.click_button(form.button_with(:value => '计划内剩余名额'))
	end

	def save_img img_url, img_name
		FileUtils.rm_f(img_name)
		@agent.get(img_url).save(img_name)
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
			code = get_info(page)
			if all.size>=1 and code==all[all.size-1]
				break
			else
				all<<code
			end
			form = page.form_with(:name => "swichXsxkActionForm")
			# form.field_with(:name => "operation").value = 'coursepage'
			form.field_with(:name => "operation").value = 'remainpage'
			form.field_with(:name => "index").value = 'next'
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
			# e.search('td[2]').map{|td|
			# 	td.text
			# }
			e.search('td').map{|td|
				td.text
			}.join(' - ')
			# puts e.search('td').map{|td|
			# 	td.text
			# }.join('-')
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
# 1600
end


