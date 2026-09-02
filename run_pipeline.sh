#!/bin/bash
# PolyFlow - Pipeline poliglota
# Ejecuta las cuatro etapas en orden y se detiene si alguna falla

set -e

BASE="/mnt/c/polyflow"
BASIC256="$BASE/herramientas/basic256/basic256.exe"
MARS="$BASE/herramientas/Mars4_5.jar"

echo "Limpiando salidas anteriores..."
rm -f "$BASE/salida/"*.csv "$BASE/salida/"*.txt

echo -n "[BASIC-256] Procesando datos... "
"$BASIC256" -s "C:\polyflow\etapa1_basic\validar.kbs" > /dev/null
echo "OK"

echo -n "[FORTRAN] Calculando metricas... "
cd "$BASE/etapa2_fortran"
gfortran -o metricas metricas.f90
./metricas > /dev/null
echo "OK"

echo -n "[JAVA] Evaluando reglas... "
cd "$BASE/etapa3_java"
javac *.java
java MotorReglas > /dev/null
echo "OK"

echo -n "[MIPS] Calculando firma... "
cd "$BASE/etapa4_mips"
java -jar "$MARS" nc firma.asm > /dev/null
echo "OK"

echo ""
echo "PIPELINE COMPLETADO"
echo ""
echo "Firma generada: $(cat "$BASE/salida/firma.txt")"
