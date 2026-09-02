# Gramatica del lenguaje de reglas - PolyFlow

## Definicion BNF

<regla>         ::= <identificador> <espacio> <operador> <espacio> <numero>

<identificador> ::= "TEMP_ALTA"
                  | "LLUVIA_INTENSA"
                  | "VIENTO_FUERTE"
                  | "BATERIA_BAJA"

<operador>      ::= ">" | "<" | ">=" | "<="

<numero>        ::= <entero> | <entero> "." <entero>

<entero>        ::= <digito> | <digito> <entero>

<digito>        ::= "0" | "1" | "2" | "3" | "4"
                  | "5" | "6" | "7" | "8" | "9"

<espacio>       ::= " " | " " <espacio>

## Reglas adicionales del archivo

Cada regla ocupa exactamente una linea.
Las lineas vacias se ignoran.
Las lineas que empiezan con # son comentarios y se ignoran.

## Ejemplos validos

TEMP_ALTA > 35
LLUVIA_INTENSA > 50
BATERIA_BAJA < 20
VIENTO_FUERTE >= 40.5

## Ejemplos invalidos

> TEMP_ALTA 35        el operador aparece donde se espera un identificador
LLUVIA_FUERTE > 50    identificador no pertenece al lenguaje
VIENTO_FUERTE >> 40   operador no pertenece al lenguaje
BATERIA_BAJA < veinte el tercer elemento no es un numero
TEMP_ALTA > 35 40     la regla tiene mas de tres elementos

## Implementacion del analisis

El analisis lexico divide la linea en tokens separados por uno o mas
espacios. El analisis sintactico verifica primero que haya exactamente
tres tokens, y luego valida cada uno segun su posicion: el primero
contra el conjunto de identificadores, el segundo contra el conjunto de
operadores, y el tercero intentando convertirlo a numero.

La validacion por posicion es lo que hace que el orden importe. En
"> TEMP_ALTA 35" el analizador encuentra ">" en la posicion del
identificador y rechaza la linea indicando exactamente esa causa.

Los errores no detienen el analisis: se acumulan y se reportan todos al
final, de modo que una regla mal escrita no invalida las demas del
archivo.
