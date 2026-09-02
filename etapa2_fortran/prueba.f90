program prueba
    implicit none
    integer :: unidad
    print *, "FORTRAN OK"
    open(newunit=unidad, file="/mnt/c/polyflow/salida/prueba_fortran.txt", status="replace")
    write(unidad, *) "hola desde fortran"
    close(unidad)
end program prueba

