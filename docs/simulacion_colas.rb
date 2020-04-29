require 'rubystats'

module Enumerable 
	def promedio
		sum / count 
	end
end

# Comercio
horario 			=  8.0	# 8 horas
capacidad 		= 5.0	# personas simultaneas
tiempo_compra 	= 25.0	# minutos por compra
utilizacion   	=  0.95	# Porcentaje de capacidad ocupada 
programada  	=  0.75	# Porcentajes de turnos programandos 

capacidad_maxima = capacidad * 60.0 / tiempo_compra

clientes_hora  = utilizacion * capacidad_maxima
clientes_total = horario * clientes_hora

franja    	=  60		# Minutos de asignacion grupal
tolerancia 	=  15		# Minutos de tolerancia

velocidad_arribo = clientes_hora 
tiempo_servicio  = tiempo_compra / capacidad 
slot 	           = ((60.0 * horario) / (clientes_total * programada)*1.5).to_i


$arribo 	 = PoissonDistribution.new(60.0 / velocidad_arribo)
$servicio = PoissonDistribution.new(tiempo_servicio)

class Cliente < Struct.new(:llegada, :programada, :inicio, :final, :duracion)
	def espera
		(self.final - self.inicio) - self.duracion
	end
	
	def to_s 
		"  llegada: %3i | inicio: %3i | final: %3i | duracion: %3.1f | espera: %4.1f | %s"  % [self.llegada, self.inicio, self.final, self.duracion, self.espera, self.programada ? "P" : "E"]
	end
end

class Poblacion < Struct.new(:cantidad, :programada, :slot)
	attr_accessor :clientes 
	include Enumerable

	def generar
		reloj = 0 
		self.clientes = (1..self.cantidad).map do 
			reloj += $arribo.rng 
			Cliente.new(reloj, rand < programada, 0, 0, $servicio.rng)
		end
	end

	def simular
		reloj = 0.0
		for c in self.clientes.sort_by(&:inicio)
			reloj = [reloj, c.inicio].max + c.duracion
			c.final  = reloj
		end
	end

	def simular_simple 
		for c in self.clientes
			c.inicio = c.llegada
		end

		simular
	end

	def simular_prioridad
		reloj = 0 
		for c in self.clientes 
			if c.programada 
				reloj += self.slot while c.llegada > reloj 
				c.inicio = reloj
				reloj += self.slot 
			else
				c.inicio = c.llegada
			end
		end
		simular
	end


	def espera
		map(&:espera).sum / count
	end

	def duracion
		map(&:duracion).sum / count
	end

	def each
		self.clientes.each{|x| yield x}
	end

	def mostrar
		puts "Hay #{count}"
		sort_by(&:inicio).each{|x| puts x}
		puts "Espera #{self.espera}"
	end
end


veces = 999
tiempo_s = []
tiempo_p = []
for v in 1..veces
	a = Poblacion.new(clientes_total, programada, slot)
	a.generar
	a.simular_simple
	a.mostrar if v == 1000
	tiempo_s   << a.espera

	a.simular_prioridad
	a.mostrar if v == 1000
	tiempo_p   << a.espera
end

puts
puts "RESUMEN"
puts "  Velocidad de arribo : %5.1f (cliente/hora)" % [velocidad_arribo]
puts "  Tiempo de Servicio  : %5.1f (minutos)" 		 % [tiempo_servicio]
puts "  Utilización         : %5.1f%% " 				 % [utilizacion * 100]
puts "  Total de clientes   : %3i   (clientes)" 	 % [clientes_hora * horario]
puts "  Slot                : %3i   (minutos)" 	    % [slot.to_i]
puts "RESULTADOS"
puts "  Espera Simple  	  : %4.2f" % a=tiempo_s.promedio.to_f
puts "  Espera Programada : %4.2f" % b=tiempo_p.promedio.to_f
puts "  Ganancia          : %3.1f%%" % (100.0*(1-b/a))
