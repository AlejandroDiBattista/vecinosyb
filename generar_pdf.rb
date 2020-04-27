Base = "/Users/alejandro/Documents/GitHub/digestodigital/ordenanzas/10_temporal/"
Origen = "#{Base}*.pdf"

require 'combine_pdf'
lista = Dir[Origen]
lista = lista.select{|x| /\d{4}\.pdf/ === x}.sort
pp lista.size
return 
pdf = CombinePDF.new
pdf << CombinePDF.load("#{Base}caratula.pdf")
puts "Generando Digesto Temporal"
lista.each do |origen| 
	print "\n#{origen}"
	pdf << CombinePDF.load(origen)
end
puts 
puts "."

pdf.save "#{Base}DigestoYB-UsoInterno.pdf"