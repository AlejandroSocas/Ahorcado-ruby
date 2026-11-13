require_relative 'figura'

# Clase ahorcado encargada de controlar la partida
class Ahorcado
  attr_reader :palabra, :palabra_secreta

  def initialize(numero_letras)
    @palabra = escoger_palabra(numero_letras).downcase # Palabra escogida al azar
    @palabra_secreta = esconder_palabra() # Palabra escogida al azar pero sututuyendo sus letras por '_'
    @vidas = 6 # Vidas restantes
    @letras_escritas = [] # Letras escritas durante la partida
  end

  # Escoge una plabar al azar de igual o más de x letras de largo
  def escoger_palabra(numero_letras)
    palabras = File.readlines("listado-general.txt", chomp:true) # Array de lineas del archivo
    palabras = palabras.shuffle # Mezcla la lista
    palabras_finales = []
    # Filtra por palabras iguales o mñas largas que numero_letras
    for palabra in palabras
      if palabra.length >= numero_letras
        palabras_finales.push(palabra)
      end
    end
    return palabras_finales.sample # Devuelve una palabra al azar
  end

  # Esconde la palabra sustituyendo sus letras por '_'
  def esconder_palabra()
    palabra_escondida = ""
    while palabra_escondida.length < @palabra.length
      palabra_escondida.concat('_')
    end
    return palabra_escondida
  end

  # Revela la letra en la palabra secreta
  def revelar_letra(letra)
    letra_encontrada = false
    # Controlamos las posibles variaciones de las vocales
    variantes = case letra
                  when 'a' then ['a', 'á']
                  when 'e' then ['e', 'é']
                  when 'i' then ['i', 'í']
                  when 'o' then ['o', 'ó']
                  when 'u' then ['u', 'ú', 'ü']
                  else [letra]
                  end
    
    # Miramos a ver si existe la letra (o sus variantes) en la palabra
    if variantes.any? { |l| @palabra.include?(l) }
      letra_encontrada = true
      indices = @palabra.chars.each_index.select { |i| variantes.include?(@palabra[i]) } # Extraemos los índices donde se encontró la letra
      for indice in indices
        @palabra_secreta[indice] = @palabra[indice] # Revelamos la(s) letra(s) en la palabra secreta
      end
    end
    return letra_encontrada
  end

  # Dibuja y modifica la salida por pantalla
  def dibujar_estado(primera_vez = false, aviso = "")
    print "\r\e[12A\e[J" unless primera_vez # Sube el cursor arriba de la terminal para modificar la salida cada iteración (sin borrarla)

    puts AHORCADO[@vidas]
    puts "Palabra: #{@palabra_secreta}"
    puts "Vidas:   #{@vidas}"
    puts "Usadas:  #{@letras_escritas.join(', ')}"
    puts aviso
    print "Letra: "
  end

  def partida()
    dibujar_estado(true) # Primera sdalida por pantalla

    while @vidas > 0
      entrada = gets.chomp.downcase # Coge la entrada del usuario

      # Si escribe salir sale del juego
      if entrada == "salir"
        return
      end
      # Si no escribe una letra vuelve a pedir la entrada
      if entrada.length != 1 || !entrada.match?(/\A[a-zA-ZñÑáéíóúÁÉÍÓÚüÜ]\z/)
        dibujar_estado(false, "Error: Introduce una letra válida (1 carácter)")
        next
      end
      # Si ya había escrito esa letra antes la vuelve a pedir
      if @letras_escritas.include?(entrada)
        dibujar_estado(false, "Introduce una letra que no hayas escrito antes.")
        next
      end

      # Guarda la letra escrita, y si está en la palabra la revela, si no resta una vida
      @letras_escritas.push(entrada)
      encontrada = revelar_letra(entrada)
      if encontrada == false
        @vidas -= 1
      end

      dibujar_estado()

      if @palabra == @palabra_secreta
        puts "\n¡Felicidades, adivinaste la palabra #{@palabra}!"
        return
      end
    end
    puts "\nHas perdido la partida, la palabra era #{@palabra}"
  end
end

# Función main
if __FILE__ == $PROGRAM_NAME
  numero_letras = 8
  numero_letras = ARGV[0].to_i if !ARGV.empty?
  ahorcado = Ahorcado.new(numero_letras)
  ARGV.clear
  ahorcado.partida()
end