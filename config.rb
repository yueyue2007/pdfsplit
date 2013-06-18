#coding:UTF-8
require	'roo'

#oo = Roo::Openoffice.new("201005.ods")
oo = Roo::Excelx.new("201005.xlsx")
oo.default_sheet = oo.sheets.first
puts oo.cell(1,'A')

