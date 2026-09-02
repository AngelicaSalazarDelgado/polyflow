public class ReglaTemperatura extends Regla {

    public ReglaTemperatura(String identificador, String operador, double umbral) {
        super(identificador, operador, umbral);
    }

    protected double extraerValor(Metrica metrica) {
        return metrica.getTempMax();
    }

    public int getCodigo() {
        return 10;
    }
}
