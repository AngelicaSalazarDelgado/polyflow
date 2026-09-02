public class ReglaBateria extends Regla {

    public ReglaBateria(String identificador, String operador, double umbral) {
        super(identificador, operador, umbral);
    }

    protected double extraerValor(Metrica metrica) {
        return metrica.getBateriaProm();
    }

    public int getCodigo() {
        return 40;
    }
}
