require "erb"
require "open-uri"
require "json"

Origen = 'C:/Users/Algacom/Desktop/Datos/*.txt'
def generar_listado
	puts lista=Dir[Origen]

	lista = lista.select{|x|x["panaderi"]}
	salida = []
	i = 0
	# lista = lista.select{|x|x[/polle/]}
	datos = lista.map do |origen|
		nombre = origen.split('/').last.split(".").first
		nombre = nombre.capitalize
		lineas = open(origen).readlines.each_slice(4).map{|x|x[0..2].to_a.map(&:chomp)}
		lineas = lineas.map{|x| x.map{|y| y.gsub(",", " ")}}
		puts
		puts nombre
		lineas = lineas.sort_by{|x|x[1]}
		lineas.each{|x|x[1] = x[1].gsub("Av ", "Av. ")}
		lineas.each{|x| puts " #{i+=1}) %-60s, %-50s, %-20s" % x}
		lineas.each{|comercio,direccion, telefono,_| salida << "#{comercio},#{nombre},#{telefono},#{direccion}" }
	end
	puts salida
end

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
		cubrir("")
	end
	
	def b
		cubrir("")
	end

	def i
		cubrir("")
	end

	def wa
		# "#{self}   [wa.me/54381#{self.gsub("-","")}]"
		"wa.me/54381#{self.gsub("-","")}"
	end

end

campos = [:id, :rubro, :nombre, :telefono, :wp, :direccion, :envios, :whatapp, :contacto, :geotag, :asignado]
orden  = ["Farmacias", "Carnicerías", "Pollerías", "Verdulerías", "Panaderías", "Almacenes", "Fiambrerías", "Pastas", "Comidas",  "Golosinas", "Helados", "Librerías",  "Computación",  "Limpieza", "Tintorerías", "Peluquería", "Semillerías", "Veterinarias", "Bebidas", "Servicios"]

datos = open('C:/Users/Algacom/Desktop/Datos/datos.tsv')
			.readlines[1..-1]
			.map{|x| x.split("\t").map(&:chomp) }
			.map{|x| campos.zip(x).to_h }
			.select{|x| x.envios == "si" }#[1..10]


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
					 	whatsapp:  s.wp,
					}
				end.sort_by{|d| d.domicilio.size > 0 ? d.domicilio : "zzzz" },
				direcciones: sucursales.count{|s|s.direccion.strip.size > 0 }
			}
		end.sort_by{|d| d.comercio }
	}
end.sort_by{|x| orden.index(x.rubro) || 99}


pp comercios.to_json
# C:\Users\Algacom\Documents\GitHub\digestodigital\code
open("vecinos.json","w+"){|f| f.write(JSON.pretty_generate(comercios))}

return
salida = []
salida << "🌟DIRECTORIO VIRTUAL DE COMERCIOS🌟"
salida << ""
salida << "Estimado vecino de YERBA BUENA hemos confeccionado un listado de comercios que realizan ENVÍOS A DOMICILIO para que no tengas que salir de casa 😷"
salida << ""
salida << "Compártela con tus amigos 😉"
salida << ""

for rubro in comercios
	salida << ""
	salida << "#{rubro.rubro.upcase.b.i} 🔖 " #" 📍" #"👈🏻"
	salida << ""

	for comercio in rubro.comercios
		if false && comercio.sucursales.size == 1 
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
# puts salida.join("\n")
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
