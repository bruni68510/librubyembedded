#!/usr/bin/env ruby

content = File.read(ARGV[0])
size = File.size(ARGV[0])

File.open(ARGV[1],"wb") do |file|
	i = 0
	file.write "unsigned char binary_data[] = {\n"
	content.each_byte do |byte|
		if i == 0
			file.write("\t")
		end
		file.write "0x" + byte.to_s(16) + ","
		if i > 10
			file.write "\n"
			i = 0
		else
			i = i + 1
		end
	end
	file.write "0x0 \n}; \n"
	file.write "unsigned long binary_size = " + size.to_s + ";\n"
end
