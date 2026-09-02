public class ReglaPrecipitacion extends Regla {

    public ReglaPrecipitacion(String identificador, String operador, double umbral) {
        super(identificador, operador, umbral);
    }

    protected double extraerValor(Metrica metrica) {
        return metrica.getLluviaTotal();
    }

    public int getCodigo() {
        return 20;
    }
}

