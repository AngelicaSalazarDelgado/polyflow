public class ReglaViento extends Regla {

    public ReglaViento(String identificador, String operador, double umbral) {
        super(identificador, operador, umbral);
    }

    protected double extraerValor(Metrica metrica) {
        return metrica.getVientoMax();
    }

    public int getCodigo() {
        return 30;
    }
}
