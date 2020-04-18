class Hash 
	def method_missing(meth, *args, &blk)
		self[meth.to_s.downcase.to_sym]
	end
end

def generar_vcard(empresa, direccion, *telefonos )
	salida = []
	salida << "BEGIN:VCARD"
	salida << "VERSION:3.0"
	salida << "ORG:#{empresa}"
	[telefonos].flatten.each{|telefono| salida << "TYPE=voice,work,pref:#{telefono}" }
	salida << "ADR:;;#{direccion},Yerba Buena,4172,Tucuman"
	salida << "END:VCARD" 
	salida.join("\n")
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
	def tel
		to_s.tel
	end
	def limpiar
		to_s.limpiar
	end
end

class NilClass
	def limpiar
		""
	end
	def wa
		""
	end
	def tl
		""
	end
end

class String
	class << self
		attr_accessor :anular_formato
	end

	def cubrir(formato)
		return self if String.anular_formato
		empty? ? "" : "#{formato}#{strip}#{formato}"
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
		tmp = tel.gsub(/\D/,"")
		tmp.empty? ? "" : "https://wa.me/54#{tmp}"
	end

	def tl
		return "" if size < 7
		"tel:+381#{gsub("-","")}"
	end

	def pad(len=30)
		(self + " " * len)[0...len]
	end

	def tel
		tmp = split("/")
				.map{|x|x.gsub(/\D/,'')[-7..-1]}
				.select{|t|t.size == 7}
				.first
		tmp ? "(381) #{tmp[0...3]}-#{tmp[3..-1]}" : ""
	end

	def telefonos
		split("/").map(&:tel)
	end

	def limpiar
		chomp.strip.gsub(/\s+/," ")
	end
end

class Object
	def empty?
		false
	end
end

class Numeric
	def empty?
		self == 0 
	end
end


class FalseClass
	def empty?
		true
	end
end


class NilClass
	def empty?
		true
	end
end

class String
	def empty?
		strip.size == 0 
	end
end