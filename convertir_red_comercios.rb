require "erb"
require "open-uri"
require "json"
require "./funciones"

Campos = [:id, :rubro, :nombre, :telefono, :whatsapp, :direccion, :localidad, :envios, :contacto, :asignado, :controlado]
OrdenRubros  = ["Farmacias", "Carnicerías", "Pollerías", "Verdulerías", "Panaderías", "Almacenes", "Fiambres", "Pastas", "Sandwichería", "Comidas", "Bares & Restaurantes", "Golosinas", "Helados", "Librerías", "Bazar",  "Tecnología",  "Limpieza", "Tintorerías", "Indumentaria & Zapatería", "Belleza", "Semillerías", "Veterinarias", "Pinturerías & Ferreteria", "Bebidas", "Servicios"]


def contar(lista)
	lista.uniq.map{|r| [r, lista.count{|x|x == r}]}.sort_by(&:last)	
end

def analizar(datos)
	puts "\n-- ANALISIS DE DATOS --\n"

	puts "\nClasificion Envios"
	contar(datos.map(&:envios)).each{|x|puts "  %-40s %3i" % x }
	
	puts "\nClasificacion Rubros"
	contar(datos.map(&:rubro)).each{|x|puts "  %-40s %3i" % x }


	puts "REVISNADO"

	mal = datos.select{|x| sin_dato(x) }
	if mal.size > 0 
		puts "Hay #{mal.size} entradas sin datos suficientes" 
		pp mal
	end

	rubros = datos.map(&:rubro).uniq
	
	sin_ordenar = rubros - OrdenRubros
	if sin_ordenar.size > 0 then
		puts "\nFalta definir el orden para..."
		pp sin_ordenar
	end
	
	sin_rubros = OrdenRubros - rubros
	if sin_rubros.size > 0 then
		puts "\nOrden obsoleto para..."
		pp sin_rubros
	end

	if mal.size == 0 && sin_ordenar.size == 0 && sin_rubros.size == 0 then
		puts "Todo OK"
	end
	puts "."
end

def leer_datos(origen='datos.tsv')
	open(origen)
		.readlines[1..-1]
		.map{|x| x.split("\t").map(&:limpiar) }
		.map{|x| Campos.zip(x).to_h }
		.select{|x|x.rubro.size > 0 }
end

def sin_dato(dato)
	sd = [datos.rubro, datos.nombre, datos.telefono, datos.whatsapp].all?(&:empty?)
	if sd 
		puts "MALLL"
		pp dato
		return true 
	else 
		puts "."
	end
	sd 
end

datos = leer_datos()
puts datos.size
puts datos.select{|x|x.envios[/si/]}.size
# pp datos
# analizar datos 

# return
i = 0
comercios = datos.group_by{|d|d.rubro}.map do |rubro, comercios|
	{
		id: i+=1,
		rubro: rubro,
		comercios: comercios.group_by{|c| c.nombre }.map do |comercio, sucursales|
			{
				nombre: comercio.gsub("FARMACIA", "Farmacia").gsub("DISTRIBUIDORA", "Distribuidora"), 
				sucursales: sucursales.map do |s|
					{
					 	domicilio: s.direccion,
					 	telefono:  s.telefono.tel,
					 	whatsapp:  s.whatsapp.tel,
					 	call: s.telefono.tl,
					 	send: s.whatsapp.wa 
					}
				end.sort_by{|d| d.domicilio.size > 0 ? d.domicilio : "zzzz" },
				direcciones: sucursales.count{|s|s.direccion.strip.size > 0 }
			}
		end.sort_by{|d| d.comercio }
	}
end.sort_by{|x| OrdenRubros.index(x.rubro) || 99}

open("docs/_data/comercios.json","w+"){|f| f.write(JSON.pretty_generate(comercios))}


return
analizar datos 
return 
salida = []
modo = :largo

if modo == :largo
	salida << "⭐DIRECTORIO VIRTUAL DE COMERCIOS⭐"

	salida << "Estimado vecino de YERBA BUENA, me sumo a la buena iniciativa del Concejal Marcelo Rojas y te invito a usar esta herramienta para evitar salir de casa 😷"
	salida << ""
	salida << "Intendente: Mariano Campero"
	salida << "Compártela con tus amigos 😉"
else	
	salida << "⭐DIRECTORIO VIRTUAL DE COMERCIOS⭐"
	salida << "Estimado vecino, estos negocios amigos te llevan los productos para que no tengas que salir de casa"
	salida << ""
	salida << "Compartilo! 😉"
	salida << "También podes consultar en www.vecinosyv.com"
end
# salida << ""
# salida << "Compartilo!"
# salida << ""

for rubro in comercios
	salida << ""
	salida << "🔖 _*#{rubro.rubro.upcase}*_" #" 📍" #"👈🏻"

	for comercio in rubro.comercios
		if true 
			salida << "- #{comercio.nombre.b}"
			# wp = comercio.sucursales.map{|x|x.whatsapp}.select{|x|x.size > 0}.map{|x|"wp: #{x}"}
			# tl = comercio.sucursales.map(&:telefono).select{|x|x.size > 0}.map{|x|"tl: #{x}"}
			wp = comercio.sucursales.map(&:whatsapp).select{|x|x.size > 0}.map{|x|"w:#{x}"}
			tl = comercio.sucursales.map(&:telefono).select{|x|x.size > 0}.map{|x|"t:#{x}"}
			aux = (wp+tl).first(3)
			salida << "  #{aux.join(' ').m}" 
			salida << ""
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

if modo == :corto 
	salida << ""
	salida << "Visitá www.vecinosyb.com"
else
	salida << ""
	salida << "Directorio elaborado por el equipo del Concejal Marcelo Rojas"
	salida << ""
	salida << "Estimado comerciante... para agregarse al listado o actualizar datos comucarse a wa.me/543814416851"
end

puts salida.join("\n")
open("enviar-whatsapp.txt","w+"){|f|f.write(salida.join("\n"))}

# categorias = datos.map(&:rubro).uniq.sort

# <iframe src="https://docs.google.com/forms/d/e/1FAIpQLSeOrcdrKs3Iy9pasQtXgaikcOh63dwMacI3Ir3QIHIJg0oXBw/viewform?embedded=true" width="640" height="1256" frameborder="0" marginheight="0" marginwidth="0">Cargando…</iframe>
# open("ale.vcf", "w+"){|f|f.write generar_vcard("Agilsoft", "Av Central 4124", "3815343458", "3814345621") }
# puts "[#{categorias.join(", ")}]"
# puts 

# datos = open('C:/Users/Algacom/Desktop/Datos/datos.tsv')
# 			.readlines[1..-1]
# 			.map{|x| x.split("\t").map(&:chomp) }
# 			.map{|x| Campos.zip(x).to_h }
# 			.select{|x| x.envios == "si" && x.wp.size == 0 }#[1..10]

# i = 0 
# datos.map(&:wp).each do |x| 
# 	puts " #{i+=1} wa.me/54381#{x.gsub("-","").strip}"
# 	puts "" if i % 10 == 0
# end
# 2
