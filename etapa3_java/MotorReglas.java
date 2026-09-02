import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class MotorReglas {

    private static final String RUTA_METRICAS = "/mnt/c/polyflow/salida/metricas.csv";
    private static final String RUTA_REGLAS = "/mnt/c/polyflow/etapa3_java/reglas.txt";
    private static final String RUTA_ALERTAS = "/mnt/c/polyflow/salida/alertas.csv";
    private static final String RUTA_SECUENCIA = "/mnt/c/polyflow/salida/secuencia.txt";

    public static void main(String[] args) throws IOException {

        List<Metrica> metricas = leerMetricas(RUTA_METRICAS);
        System.out.println("Estaciones leidas: " + metricas.size());

        ParserReglas parser = new ParserReglas();
        List<Regla> reglas = parser.parsear(RUTA_REGLAS);
        System.out.println("Reglas validas: " + reglas.size());

        for (String error : parser.getErrores()) {
            System.out.println("ERROR DE SINTAXIS -> " + error);
        }

        FileWriter alertas = new FileWriter(RUTA_ALERTAS);
        FileWriter secuencia = new FileWriter(RUTA_SECUENCIA);

        alertas.write("ESTACION,REGLA,VALOR,UMBRAL\n");

        int totalAlertas = 0;

        for (Metrica metrica : metricas) {
            for (Regla regla : reglas) {
                if (regla.evaluar(metrica)) {
                    double valor = regla.extraerValorPublico(metrica);
                    alertas.write(metrica.getEstacion() + ","
                                + regla.getIdentificador() + ","
                                + String.format("%.2f", valor) + ","
                                + String.format("%.2f", regla.getUmbral()) + "\n");
                    secuencia.write(regla.getCodigo() + "\n");
                    totalAlertas++;
                }
            }
        }

        alertas.close();
        secuencia.close();

        System.out.println("Alertas generadas: " + totalAlertas);
    }

    private static List<Metrica> leerMetricas(String ruta) throws IOException {
        List<Metrica> lista = new ArrayList<Metrica>();
        BufferedReader lector = new BufferedReader(new FileReader(ruta));

        lector.readLine();

        String linea;
        while ((linea = lector.readLine()) != null) {
            linea = linea.trim();
            if (linea.isEmpty()) {
                continue;
            }
            String[] campos = linea.split(",");
            lista.add(new Metrica(
                campos[0],
                Double.parseDouble(campos[1]),
                Double.parseDouble(campos[2]),
                Double.parseDouble(campos[3]),
                Double.parseDouble(campos[4]),
                Double.parseDouble(campos[5]),
                Double.parseDouble(campos[6]),
                Double.parseDouble(campos[7])
            ));
        }

        lector.close();
        return lista;
    }
}
