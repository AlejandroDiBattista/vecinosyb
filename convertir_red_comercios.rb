require "erb"
require "open-uri"
require "json"
require "./funciones"

Campos = [:id, :rubro, :nombre, :telefono, :whatsapp, :direccion, :localidad, :envios, :contacto, :asignado, :controlado]

OrdenRubros    = ["Farmacias", "Carnicerías", "Pollerías", "Verdulerías", "Panaderías", "Almacenes", "Fiambres", "Pastas", "Sandwichería", "Comidas", "Bares & Restaurantes", "Golosinas", "Helados", "Bebidas", "Librerías", "Bazar", "Jugueterías", "Tecnología",  "Limpieza", "Tintorerías", "Indumentaria & Zapatería", "Belleza", "Semillerías", "Veterinarias", "Pinturerías & Ferreteria", "Servicios", "Marketing Digital", "Piletas", "Electricidad"]
IncluirRubros  = ["Farmacias", "Carnicerías", "Pollerías", "Verdulerías", "Panaderías", "Almacenes", "Fiambres", "Pastas", "Sandwichería", "Comidas", "Golosinas", "Helados", "Bebidas",  "Limpieza", "Semillerías", "Veterinarias"]

def contar(lista)
	lista.uniq.map{|r| [r, lista.count{|x|x == r}]}.sort_by(&:last)	
end

def analizar(datos)
	puts "\n-- ANALISIS DE DATOS --\n"

	puts "\nClasificion Envios"
	contar(datos.map(&:envios)).each{|x|puts "  %-40s %3i" % x }
	
	puts "\nClasificacion Rubros"
	contar(datos.map(&:rubro)).each{|x|puts "  %-40s %3i" % x }


	puts "REVISANDO"

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

	ok = [mal, sin_ordenar, sin_rubros].all?(&:empty?)
	puts ok ? "Todo OK :)" : "Mal :("
	ok 
end

def leer_datos(origen='datos.tsv')
	open(origen)
		.readlines[1..-1]
		.map{|x| x.split("\t").map(&:limpiar) }
		.map{|x| Campos.zip(x).to_h }
		.select{|x|!x.rubro.empty? }
end

def sin_dato(dato)
	if dato.rubro.empty? || dato.nombre.empty? || (dato.telefono.empty? && dato.whatsapp.empty?)
		puts ">>> MAL :)"
		pp dato
		true 
	else 
		false 
	end
end

def rubro_id(rubro)
	rubro.strip.downcase.gsub(/[^a-záéíóú]+/,"_").gsub("é","e").gsub("í","i").gsub("ó","ó").gsub("ú","u")
end

def generar_comercios(datos)
	i = 0
	datos.group_by{|d|d.rubro}.map do |rubro, comercios|
		{
			id: rubro_id(rubro),
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
				},
			}
			end.sort_by{|d| d.comercio }
		}
	end.sort_by{|x| OrdenRubros.index(x.rubro) || 99}
end

def agregar_busqueda(datos)
	datos.each do |dato|
		dato.seach = [dato.rubro, dato.comercios.map(&:nombre), dato.comercios.map{|x| x.sucursales.map{|y| [x.domicilio, x.telefono, x.whatsapp]}}
	end
end

def generar_whatsapp(comercios, modo, formato=false)
	salida = []
	String.anular_formato = !formato 
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

	for rubro in comercios
		salida << ""
		salida << "🔖 _*#{rubro.rubro.upcase}*_" #" 📍" #"👈🏻"

		puts rubro if rubro.comercios.nil?
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

	if modo == :largo 
		salida << ""
		salida << "Directorio elaborado por el equipo del Concejal Marcelo Rojas"
		salida << ""
		salida << "Estimado comerciante... para agregarse al listado o actualizar datos comucarse a wa.me/543814416851"
	else
		salida << ""
		salida << "Visitá www.vecinosyb.com"
	end

	salida.join("\n")
end

datos = leer_datos()

if analizar(datos)

	p datos.size
	datos = datos.select{|x|/si/ === x.envios}
	p datos.size
	datos = datos.select{|x| IncluirRubros.include?(x.rubro) }
	p datos.size
	
	comercios = generar_comercios(datos)
	rubros = comercios.map{|x| {id: x.id, nombre: x.rubro, cantidad: x.comercios.count } }.sort_by(&:nombre)

	open("docs/_data/comercios.json","w+"){|f| f.write(JSON.pretty_generate(comercios))}
	open("docs/_data/rubros.json","w+"){|f| f.write(JSON.pretty_generate(rubros))}

	whatsapp = generar_whatsapp(comercios, :corto)
	open("docs/_data/whatsapp_corto.txt","w+"){|f| f.write(whatsapp)}

	whatsapp = generar_whatsapp(comercios, :largo)
	open("docs/_data/whatsapp_corto.txt","w+"){|f| f.write(whatsapp)}
end	
puts "Todo OK!!"