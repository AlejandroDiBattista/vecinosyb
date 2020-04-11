require "erb"
require "open-uri"
require "json"

def normalizar(texto, pre="", pos="")
	texto = texto.strip#.gsub("-", "")
	texto == "" ? "" : "#{pre}#{texto}#{pos}"
end

class Hash 
	def method_missing(meth, *args, &blk)
		self[meth.to_s.downcase.to_sym]
	end
end

class Object
	def m
		to_s.m
	end
	def b
		to_s.b
	end
	def i
		to_s.i
	end
end

class String
	def cubrir(formato)
		return "" if strip == ""
		"#{formato}#{strip}#{formato}"
	end

	def m
		cubrir("```")
	end
	
	def b
		cubrir("*")
	end

	def i
		cubrir("_")
	end

	def wa
		"wa.me/54381#{self.gsub("-","")}"
	end

	def pad(len=30)
		(self + " " * len)[0...len]
	end
end

campos = [:id, :rubro, :nombre, :telefono, :whatsapp, :direccion, :envios, :contacto, :asignado, :controlado]
orden  = ["Farmacias", "Carnicerías", "Pollerías", "Verdulerías", "Panaderías", "Almacenes", "Fiambrerías", "Pastas", "Comidas",  "Golosinas", "Helados", "Librerías",  "Computación",  "Limpieza", "Tintorerías", "Peluquería", "Semillerías", "Veterinarias", "Bebidas", "Servicios"]

datos = open('datos.tsv')
			.readlines[1..-1]
			.map{|x| x.split("\t").map(&:chomp) }
			.map{|x| campos.zip(x).to_h }
			.select{|x| x.envios == "si" }


comercios = datos.group_by{|d|d.rubro}.map do |rubro, comercios|
	{
		rubro: rubro,
		comercios: comercios.group_by{|c| c.nombre }.map do |comercio, sucursales|
			{
				nombre: comercio.upcase.gsub("FARMACIA", "Farmacia").gsub("DISTRIBUIDORA", "Distribuidora"), 
				sucursales: sucursales.map do |s|
					{
					 	domicilio: s.direccion,
					 	telefono:  s.telefono,
					 	whatsapp:  s.whatsapp,
					}
				end.sort_by{|d| d.domicilio.size > 0 ? d.domicilio : "zzzz" },
				direcciones: sucursales.count{|s|s.direccion.strip.size > 0 }
			}
		end.sort_by{|d| d.comercio }
	}
end.sort_by{|x| orden.index(x.rubro) || 99}

# pp comercios
open("vecinos.json","w+"){|f| f.write(JSON.pretty_generate(comercios))}


salida = []
salida << "⭐*Yerba Buena - Envio a domicilio*⭐"
salida << "_Compartilo!_"
# salida << ""
# salida << "Compartilo!"
# salida << ""

for rubro in comercios
	salida << ""
	salida << "🔖_*#{rubro.rubro.upcase}*_" #" 📍" #"👈🏻"
	salida << ""

	for comercio in rubro.comercios
		if true 
			salida << "- #{comercio.nombre.b}"
			wp = comercio.sucursales.map{|x|x.whatsapp}.select{|x|x.size > 0}.map{|x|"wp: #{x}"}
			tl = comercio.sucursales.map(&:telefono).select{|x|x.size > 0}.map{|x|"tl: #{x}"}
			aux = (wp+tl).first(3)
			salida << "  #{aux.join(' ').m}" 
			# p salida.last if wp.size > 1 || tl.size > 1 || wp.size + tl.size > 2 

		elsif false && comercio.sucursales.size == 1 
			sucursal = comercio.sucursales.first
			salida << "#{comercio.nombre.b}   #{sucursal.domicilio.i}"
			salida << " 🤳 #{sucursal.whatsapp.wa}"  	if sucursal.whatsapp.size  > 0 
			salida << " ☎️ #{sucursal.telefono}" 	  	if sucursal.telefono.size  > 0 
			salida << ""
		else
			salida << "#{comercio.nombre.b}"
			for sucursal in comercio.sucursales
				salida << " 🤳 #{sucursal.whatsapp.wa}"	if sucursal.whatsapp.size  > 0 
				salida << " ☎️ #{sucursal.telefono}" 	if sucursal.telefono.size  > 0 
				salida << " 📍 #{sucursal.domicilio.m}" 	if sucursal.domicilio.size > 0 
				salida << ""
			end
		end

	end
end
salida << ""
salida << "Lista creada por 'Vecinos de Yerba Buena'"
salida << "Para agregar un comercio o recibir actualizaciones comunícate a wa.me/543814416851"
salida 
puts salida.join("\n")
# puts 

# datos = open('C:/Users/Algacom/Desktop/Datos/datos.tsv')
# 			.readlines[1..-1]
# 			.map{|x| x.split("\t").map(&:chomp) }
# 			.map{|x| campos.zip(x).to_h }
# 			.select{|x| x.envios == "si" && x.wp.size == 0 }#[1..10]

# i = 0 
# datos.map(&:wp).each do |x| 
# 	puts " #{i+=1} wa.me/54381#{x.gsub("-","").strip}"
# 	puts "" if i % 10 == 0
# end
# 2
