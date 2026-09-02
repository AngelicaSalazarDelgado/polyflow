public class Metrica {
    private String estacion;
    private double tempProm;
    private double tempMax;
    private double tempMin;
    private double lluviaTotal;
    private double vientoProm;
    private double vientoMax;
    private double bateriaProm;

    public Metrica(String estacion, double tempProm, double tempMax, double tempMin,
                   double lluviaTotal, double vientoProm, double vientoMax,
                   double bateriaProm) {
        this.estacion = estacion;
        this.tempProm = tempProm;
        this.tempMax = tempMax;
        this.tempMin = tempMin;
        this.lluviaTotal = lluviaTotal;
        this.vientoProm = vientoProm;
        this.vientoMax = vientoMax;
        this.bateriaProm = bateriaProm;
    }

    public String getEstacion() { return estacion; }
    public double getTempProm() { return tempProm; }
    public double getTempMax() { return tempMax; }
    public double getTempMin() { return tempMin; }
    public double getLluviaTotal() { return lluviaTotal; }
    public double getVientoProm() { return vientoProm; }
    public double getVientoMax() { return vientoMax; }
    public double getBateriaProm() { return bateriaProm; }
}
