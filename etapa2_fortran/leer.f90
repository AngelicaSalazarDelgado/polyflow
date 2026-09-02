program leer
    implicit none
    integer :: unidad, estado, contador
    character(len=100) :: encabezado
    character(len=10) :: id
    character(len=20) :: estacion
    real :: temperatura, precipitacion, viento, bateria

    open(newunit=unidad, file="/mnt/c/polyflow/salida/datos_normalizados.csv", &
         status="old", action="read")

    read(unidad, '(A)') encabezado
    print *, "Encabezado: ", trim(encabezado)

    contador = 0
    do
        read(unidad, *, iostat=estado) id, estacion, temperatura, &
                                       precipitacion, viento, bateria
        if (estado /= 0) exit
        contador = contador + 1
        print *, trim(id), " ", trim(estacion), temperatura, bateria
    end do

    close(unidad)
    print *, "Filas leidas: ", contador
end program leer
