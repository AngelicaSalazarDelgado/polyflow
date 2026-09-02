# PolyFlow

Pipeline poliglota para procesamiento de datos de estaciones ambientales.
Proyecto 1 del curso Paradigmas de Programacion, Universidad Nacional.

Cuatro programas escritos en lenguajes distintos colaboran para resolver
un mismo problema. Cada uno recibe el archivo que produjo el anterior y
entrega el que consumira el siguiente. No son cuatro programas
independientes: son un solo sistema.

## Arquitectura

    datos/lecturas.csv
            |
            v
    [ BASIC-256 ]  validacion y limpieza
            |
            v
    salida/datos_normalizados.csv  (+ rechazados.csv)
            |
            v
    [ FORTRAN ]  calculo de metricas por estacion
            |
            v
    salida/metricas.csv
            |
            v
    [ JAVA ]  parser de reglas y motor de evaluacion
            |
            v
    salida/alertas.csv  +  salida/secuencia.txt
            |
            v
    [ MIPS ]  checksum de verificacion
            |
            v
    salida/firma.txt

## Requisitos

- Windows con WSL2 (Ubuntu)
- BASIC-256 2.1.1 o superior (Windows, version portable)
- gfortran
- JDK 17 o superior
- MARS 4.5 (Mars4_5.jar)

## Instalacion desde el repositorio

El repositorio no incluye las herramientas de terceros ni las carpetas
generadas. Despues de clonar:

1. Crear la carpeta de salida:

        mkdir -p salida

2. Descargar MARS 4.5 desde el repositorio dpetersanderson/MARS en
   GitHub y guardar el archivo Mars4_5.jar en `herramientas/`.

3. Descargar BASIC-256 2.1.1 (version portable para Windows) desde
   basic256.org y extraerlo en `herramientas/basic256/`, de modo que
   quede `herramientas/basic256/basic256.exe`.

4. Dar permiso de ejecucion al script:

        chmod +x run_pipeline.sh

El proyecto asume la ruta `C:\polyflow` porque BASIC-256 corre del lado
de Windows con rutas absolutas. Si se clona en otra ubicacion, hay que
ajustar las rutas en `etapa1_basic/validar.kbs` y en `run_pipeline.sh`.

## Ejecucion

Pipeline completo desde la raiz del proyecto:

    ./run_pipeline.sh

Salida esperada:

    [BASIC-256] Procesando datos... OK
    [FORTRAN] Calculando metricas... OK
    [JAVA] Evaluando reglas... OK
    [MIPS] Calculando firma... OK

    PIPELINE COMPLETADO

    Firma generada: 129

El script borra el contenido de `salida/` antes de empezar, de modo que
todos los archivos intermedios se regeneran en cada corrida. Si una
etapa falla, el script se detiene y no continua con la siguiente.

## Ejecucion por etapas

Etapa 1, validacion:

    herramientas/basic256/basic256.exe -s "C:\polyflow\etapa1_basic\validar.kbs"

Etapa 2, metricas:

    cd etapa2_fortran && gfortran -o metricas metricas.f90 && ./metricas

Etapa 3, reglas:

    cd etapa3_java && javac *.java && java MotorReglas

Etapa 4, checksum:

    cd etapa4_mips && java -jar ../herramientas/Mars4_5.jar nc firma.asm

## Contratos entre etapas

Formato comun: separador coma, punto decimal, sin espacios alrededor de
las comas, primera linea de encabezado que cada etapa descarta al leer.

`datos/lecturas.csv` y `salida/datos_normalizados.csv`:

    ID,ESTACION,TEMPERATURA,PRECIPITACION,VIENTO,BATERIA
    001,COTO,31,12,18,82

`salida/rechazados.csv`:

    ID,MOTIVO
    007,TEMPERATURA_FUERA_DE_RANGO

`salida/metricas.csv`, una fila por estacion:

    ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM
    COTO,33.67,36.00,31.00,42.00,23.67,28.00,67.67

`salida/alertas.csv`:

    ESTACION,REGLA,VALOR,UMBRAL
    COTO,TEMP_ALTA,36.00,35.00

`salida/secuencia.txt`, un codigo por linea:

    10
    20

`salida/firma.txt`, el checksum:

    129

## Etapa 1 - BASIC-256 (validar.kbs)

Lee `lecturas.csv` y decide que registros continuan. Se descarta el
registro completo cuando cualquier campo es invalido.

| Validacion | Motivo registrado |
|---|---|
| Algun campo vacio | CAMPO_VACIO |
| Temperatura fuera de [-10, 60] | TEMPERATURA_FUERA_DE_RANGO |
| Precipitacion negativa | PRECIPITACION_NEGATIVA |
| Viento negativo | VIENTO_NEGATIVO |
| Bateria fuera de [0, 100] | BATERIA_FUERA_DE_RANGO |

La verificacion de campo vacio va primero: un campo sin contenido no se
puede convertir a numero, y una validacion de rango posterior operaria
sobre un cero falso.

Paradigma imperativo: variable de estado `motivo$` que funciona como
bandera de validez, ciclo `while` de lectura linea por linea, y
separacion manual de campos consumiendo progresivamente una variable
con `instr` y `mid`, ya que BASIC-256 no tiene funcion de division de
cadenas.

## Etapa 2 - Fortran (metricas.f90)

Lee `datos_normalizados.csv` y calcula ocho metricas agrupadas por
estacion. Como Fortran no tiene diccionarios, la agrupacion usa
arreglos paralelos: la posicion i de cada arreglo corresponde siempre a
la misma estacion.

Paradigma procedural: acumuladores de estado actualizados dentro de un
ciclo `do`, control explicito de fin de archivo con `iostat`, y
escritura con formato explicito para respetar el contrato.

## Etapa 3 - Java (MotorReglas.java)

Lee `metricas.csv` y `reglas.txt`, parsea las reglas validando la
gramatica, las evalua contra cada estacion y genera `alertas.csv` y
`secuencia.txt`.

Las reglas se definen fuera del codigo:

    TEMP_ALTA > 35
    LLUVIA_INTENSA > 50
    VIENTO_FUERTE > 40
    BATERIA_BAJA < 20

La gramatica completa esta en `etapa3_java/GRAMATICA.md`. El archivo
`reglas_invalidas.txt` contiene errores intencionales para verificar
que el parser los detecta y reporta con numero de linea y causa.

Herencia y polimorfismo: la clase abstracta `Regla` implementa
`evaluar()` una sola vez y declara abstracto solo `extraerValor()`.
Cada subclase consulta la columna que corresponde a su fenomeno:
temperatura el maximo, lluvia el acumulado, viento la rafaga maxima,
bateria el promedio. La comparacion es comun, la extraccion es lo que
varia.

## Etapa 4 - MIPS (firma.asm)

Lee `secuencia.txt` y aplica la formula del enunciado: suma el valor y
aplica XOR con la posicion, contando desde 1.

MIPS no distingue entre texto y numero: el programa recorre el buffer
byte por byte, reconoce los digitos por su rango ASCII y arma cada
valor con `numero * 10 + digito`. Para escribir el resultado hace el
camino inverso con divisiones y restos sucesivos.

## Estructura

    datos/            datos de entrada
    salida/           archivos generados por el pipeline
    etapa1_basic/     validacion en BASIC-256
    etapa2_fortran/   calculo de metricas
    etapa3_java/      parser, reglas y motor
    etapa4_mips/      checksum en ensamblador
    herramientas/     BASIC-256 y MARS (no versionado)
    run_pipeline.sh   automatizacion completa
    README.md         este archivo
    DECISIONES.md     decisiones de diseño y justificaciones
    INFORME.md        informe tecnico
    etapa3_java/GRAMATICA.md   gramatica del lenguaje de reglas


