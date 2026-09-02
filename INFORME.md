# Informe tecnico - PolyFlow

Angelica Salazar Delgado
Paradigmas de Programacion, Universidad Nacional

## 1. Problema y enfoque

El proyecto construye un sistema unico repartido en cuatro lenguajes,
donde la salida de cada programa es la entrada del siguiente. El
escenario es una red de estaciones ambientales que reporta lecturas con
errores de sensor: el pipeline las valida, calcula metricas por
estacion, evalua reglas de alerta y produce un codigo de verificacion.

La asignacion de lenguajes no es arbitraria. Cada etapa se resolvio en
el lenguaje cuyo paradigma corresponde a la naturaleza del problema:
control de flujo y cambio de estado en BASIC-256, calculo numerico en
Fortran, abstraccion y polimorfismo en Java, y manipulacion directa de
memoria en ensamblador MIPS.

## 2. Los contratos

La pregunta central del proyecto es como puede un programa en Fortran
entender lo que produjo BASIC-256. La respuesta es que no necesita
entenderlo: necesita conocer el formato del archivo.

Se definio un formato comun antes de escribir una sola linea de codigo:
separador coma, punto decimal, sin espacios alrededor de las comas, y
primera linea de encabezado que cada etapa descarta al leer.

| Etapa | Archivo | Encabezado |
|---|---|---|
| entrada | lecturas.csv | ID,ESTACION,TEMPERATURA,PRECIPITACION,VIENTO,BATERIA |
| BASIC-256 | datos_normalizados.csv | igual al de entrada |
| Fortran | metricas.csv | ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM |
| Java | alertas.csv | ESTACION,REGLA,VALOR,UMBRAL |
| Java | secuencia.txt | un codigo numerico por linea |
| MIPS | firma.txt | checksum |

Fijar el contrato primero permitio desarrollar y probar cada etapa por
separado. Ningun programa conoce la implementacion del anterior.

## 3. Etapa 1: validacion en BASIC-256

La etapa decide que registros continuan. Se descarta el registro
completo cuando cualquier campo es invalido, siguiendo el enunciado,
que habla de decidir registros y no campos.

El orden de las validaciones no es indiferente. La verificacion de
campo vacio va primero porque un campo sin contenido no se puede
convertir a numero, y cualquier validacion de rango posterior operaria
sobre un cero falso que pasaria todos los filtros.

BASIC-256 no tiene funcion de division de cadenas, de modo que los
campos se separan recorriendo la linea con instr y mid sobre una
variable que se acorta en cada iteracion. Ese consumo progresivo de una
variable dentro de un ciclo es el paradigma imperativo en su forma mas
directa: el estado del programa es lo que queda por procesar.

Resultado con los datos de prueba: de 15 registros, 8 continuan y 7 se
descartan. Los motivos quedan documentados en rechazados.csv, un
archivo adicional que no pide el enunciado pero que permite verificar
que cada validacion atrapa lo que debe.

## 4. Etapa 2: metricas en Fortran

Fortran calcula ocho metricas por estacion. El desafio no es
aritmetico sino estructural: el lenguaje no ofrece diccionarios, asi
que agrupar por estacion exige arreglos paralelos donde la posicion i
de cada arreglo corresponde siempre a la misma estacion. Es la
mecanica que un diccionario esconde, escrita a mano.

Los acumuladores de maximo se inicializan en -1000 y los de minimo en
1000, para que la primera comparacion siempre los reemplace.
Inicializar los maximos en cero produciria un maximo de cero si todas
las lecturas fueran negativas, un valor que nunca se midio.

La escritura usa formato explicito. El formato libre de Fortran agrega
un espacio de relleno al inicio de cada linea y siete decimales
innecesarios, lo que habria roto el parser de la etapa siguiente. Es un
ejemplo concreto de como el contrato disciplina la implementacion.

## 5. Etapa 3: gramatica, parser y polimorfismo

Las reglas no estan en el codigo sino en reglas.txt, lo que obliga a
interpretarlas en tiempo de ejecucion.

La gramatica define una regla como identificador, operador y numero, en
ese orden. El analisis lexico divide la linea en tokens y el sintactico
valida cada uno segun su posicion. Esa validacion posicional es lo que
hace que "> TEMP_ALTA 35" sea invalida: el analizador encuentra un
operador donde espera un identificador.

Los errores se acumulan en lugar de detener el programa. Con un archivo
de seis lineas que contiene cinco errores intencionales, el parser
acepta la unica regla valida y reporta los cinco problemas con su
numero de linea y su causa especifica.

La jerarquia de clases resuelve un problema conceptual real. Todas las
reglas comparan un valor contra un umbral, pero cada una debe consultar
una columna distinta de las metricas: temperatura alta mira el maximo,
porque un pico de calor importa aunque el promedio sea normal; lluvia
intensa mira el acumulado, porque asi se mide una tormenta; viento
fuerte mira la rafaga maxima; y bateria baja mira el promedio, porque
una lectura baja aislada puede ser ruido del sensor.

Por eso la clase abstracta Regla implementa evaluar() una sola vez y
declara abstracto unicamente extraerValor(). La comparacion es comun,
la extraccion es lo que varia. Reescribir evaluar() en cada subclase
habria duplicado el mismo codigo cuatro veces sin ganar nada.

El caso de COTO demuestra que la eleccion tiene consecuencias: su
temperatura promedio es 33.67, por debajo del umbral de 35, pero su
maxima es 36. La alerta existe porque ReglaTemperatura consulta el
maximo. Con otra columna, esa alerta no se generaria.

## 6. Etapa 4: checksum en MIPS

La etapa lee secuencia.txt, donde Java escribio un codigo numerico por
cada alerta, y aplica la formula del enunciado: sumar el valor y
aplicar XOR con la posicion.

El enunciado no indica desde que valor cuenta la posicion. Se decidio
contar desde 1, porque con posicion 0 el primer XOR seria neutro y el
primer elemento de la secuencia no afectaria el resultado.

El trabajo real esta en la conversion. MIPS no distingue entre texto y
numero: en memoria hay bytes con codigos ASCII. El programa recorre el
buffer byte por byte, reconoce los digitos por su rango numerico, y
arma cada valor con la formula numero por diez mas digito. Para
escribir el resultado hace el camino inverso mediante divisiones y
restos sucesivos.

El contraste con las etapas previas es el punto de la etapa. Lo que en
Java es una llamada a Double.parseDouble, aqui es un ciclo de veinte
instrucciones que hay que escribir, entender y depurar.

El resultado con la secuencia de prueba es 129, valor que se calculo a
mano antes de programar para poder verificar la salida en lugar de
aceptar cualquier numero.

## 7. Integracion

El script run_pipeline.sh ejecuta las cuatro etapas con un solo
comando. Antes de empezar borra el contenido de salida/, de modo que
todos los archivos intermedios se regeneran en cada corrida.

Usa set -e para abortar apenas una etapa devuelva error, evitando que
una etapa posterior procese archivos de una corrida anterior. Fortran y
Java se recompilan en cada ejecucion.

La automatizacion completa fue posible porque BASIC-256 2.1.1 incluye
una opcion de ejecucion sin interfaz grafica que devuelve codigo de
salida. Versiones anteriores no lo permitian.

## 8. Metodo de trabajo

Dos habitos resultaron decisivos.

El primero fue probar la parte riesgosa de cada etapa antes de escribir
la etapa completa: separar una sola linea antes de validar quince,
leer el CSV antes de calcular metricas, leer el archivo antes de
calcular el checksum. Cuando algo fallaba, el error estaba en quince
lineas y no en ochenta.

El segundo fue medir en lugar de suponer. Al procesar el primer CSV, el
ultimo campo aparecia partido en dos lineas y la hipotesis inicial fue
un error de concatenacion. Imprimir la longitud de cada campo mostro
que el campo tenia tres caracteres en lugar de dos: habia un salto de
linea invisible pegado al final. La medicion descarto la hipotesis
equivocada y senalo la correcta.

## 9. Conclusion

El proyecto muestra que la integracion entre lenguajes no depende de
que se parezcan, sino de que respeten un formato acordado. Los cuatro
programas no comparten memoria, tipos ni convenciones, y aun asi
funcionan como un sistema unico porque cada uno sabe exactamente que
archivo recibe y cual debe entregar.

Tambien deja ver el costo de la abstraccion. Convertir texto en numero
es una llamada en Java, una instruccion en Fortran, y un ciclo escrito
a mano en MIPS. Ninguna es mejor: cada nivel de abstraccion oculta
trabajo que alguien, en algun nivel, tuvo que escribir.
