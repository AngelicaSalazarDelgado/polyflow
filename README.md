# PolyFlow

Pipeline poliglota para procesamiento de datos de estaciones ambientales.
Proyecto 1 del curso Paradigmas de Programacion, Universidad Nacional.

Cuatro programas escritos en lenguajes distintos colaboran para resolver
un mismo problema. Cada uno recibe el archivo que produjo el anterior y
entrega el que consumira el siguiente.

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
- BASIC-256 version 2.1.1 o superior (Windows, portable)
- gfortran
- JDK 17 o superior
- MARS 4.5 (Mars4_5.jar)

Las herramientas de terceros se ubican en `herramientas/` y no se
incluyen en el repositorio.

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

## Ejecucion por etapas

Etapa 1, validacion:

    herramientas/basic256/basic256.exe -s "C:\polyflow\etapa1_basic\validar.kbs"

Etapa 2, metricas:

    cd etapa2_fortran && gfortran -o metricas metricas.f90 && ./metricas

Etapa 3, reglas:

    cd etapa3_java && javac *.java && java MotorReglas

Etapa 4, checksum:

    cd etapa4_mips && java -jar ../herramientas/Mars4_5.jar nc firma.asm

## Estructura

    datos/            datos de entrada
    salida/           archivos generados por el pipeline
    etapa1_basic/     validacion en BASIC-256
    etapa2_fortran/   calculo de metricas
    etapa3_java/      parser, reglas y motor
    etapa4_mips/      checksum en ensamblador
    herramientas/     BASIC-256 y MARS (no versionado)
    run_pipeline.sh   automatizacion completa
    DECISIONES.md     decisiones de diseño y justificaciones
    etapa3_java/GRAMATICA.md   gramatica del lenguaje de reglas

## Lenguaje de reglas

Las reglas se definen en `etapa3_java/reglas.txt`, fuera del codigo:

    TEMP_ALTA > 35
    LLUVIA_INTENSA > 50
    VIENTO_FUERTE > 40
    BATERIA_BAJA < 20

La gramatica completa esta en `etapa3_java/GRAMATICA.md`. El archivo
`reglas_invalidas.txt` contiene errores intencionales para verificar
que el parser los detecta.
