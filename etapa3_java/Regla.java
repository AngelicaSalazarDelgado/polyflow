public abstract class Regla {
    protected String identificador;
    protected String operador;
    protected double umbral;

    public Regla(String identificador, String operador, double umbral) {
        this.identificador = identificador;
        this.operador = operador;
        this.umbral = umbral;
    }

    protected abstract double extraerValor(Metrica metrica);

    public boolean evaluar(Metrica metrica) {
        double valor = extraerValor(metrica);
        if (operador.equals(">")) {
            return valor > umbral;
        } else if (operador.equals("<")) {
            return valor < umbral;
        } else if (operador.equals(">=")) {
            return valor >= umbral;
        } else if (operador.equals("<=")) {
            return valor <= umbral;
        }
        return false;
    }

    public String getIdentificador() { return identificador; }
    public double getUmbral() { return umbral; }
    public abstract int getCodigo();
    public double extraerValorPublico(Metrica metrica) {
        return extraerValor(metrica);
    }
}
