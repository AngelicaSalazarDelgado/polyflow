program metricas
    implicit none

    integer, parameter :: MAX_ESTACIONES = 50
    integer :: unidad_entrada, unidad_salida, estado, i, indice, n_estaciones

    character(len=20) :: nombres(MAX_ESTACIONES)
    integer :: conteo(MAX_ESTACIONES)
    real :: suma_temp(MAX_ESTACIONES), max_temp(MAX_ESTACIONES), min_temp(MAX_ESTACIONES)
    real :: suma_lluvia(MAX_ESTACIONES)
    real :: suma_viento(MAX_ESTACIONES), max_viento(MAX_ESTACIONES)
    real :: suma_bateria(MAX_ESTACIONES)

    character(len=100) :: encabezado
    character(len=10) :: id
    character(len=20) :: estacion
    real :: temperatura, precipitacion, viento, bateria

    n_estaciones = 0
    conteo = 0
    suma_temp = 0.0
    suma_lluvia = 0.0
    suma_viento = 0.0
    suma_bateria = 0.0
    max_temp = -1000.0
    min_temp = 1000.0
    max_viento = -1000.0

    open(newunit=unidad_entrada, file="/mnt/c/polyflow/salida/datos_normalizados.csv", &
         status="old", action="read")
    read(unidad_entrada, '(A)') encabezado

    do
        read(unidad_entrada, *, iostat=estado) id, estacion, temperatura, &
                                               precipitacion, viento, bateria
        if (estado /= 0) exit

        indice = 0
        do i = 1, n_estaciones
            if (trim(nombres(i)) == trim(estacion)) then
                indice = i
                exit
            end if
        end do

        if (indice == 0) then
            n_estaciones = n_estaciones + 1
            indice = n_estaciones
            nombres(indice) = estacion
        end if

        conteo(indice) = conteo(indice) + 1
        suma_temp(indice) = suma_temp(indice) + temperatura
        suma_lluvia(indice) = suma_lluvia(indice) + precipitacion
        suma_viento(indice) = suma_viento(indice) + viento
        suma_bateria(indice) = suma_bateria(indice) + bateria

        if (temperatura > max_temp(indice)) max_temp(indice) = temperatura
        if (temperatura < min_temp(indice)) min_temp(indice) = temperatura
        if (viento > max_viento(indice)) max_viento(indice) = viento
    end do

    close(unidad_entrada)

    open(newunit=unidad_salida, file="/mnt/c/polyflow/salida/metricas.csv", &
         status="replace", action="write")

    write(unidad_salida, '(A)') "ESTACION,TEMP_PROM,TEMP_MAX,TEMP_MIN,LLUVIA_TOTAL,VIENTO_PROM,VIENTO_MAX,BATERIA_PROM"

    do i = 1, n_estaciones
        write(unidad_salida, '(A,7(",",F0.2))') trim(nombres(i)), &
            suma_temp(i) / conteo(i), &
            max_temp(i), &
            min_temp(i), &
            suma_lluvia(i), &
            suma_viento(i) / conteo(i), &
            max_viento(i), &
            suma_bateria(i) / conteo(i)
    end do

    close(unidad_salida)

    print *, "Estaciones procesadas: ", n_estaciones
end program metricas
