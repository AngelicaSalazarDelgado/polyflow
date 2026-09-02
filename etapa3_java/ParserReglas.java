import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ParserReglas {

    private List<String> errores = new ArrayList<String>();

    public List<Regla> parsear(String ruta) throws IOException {
        List<Regla> reglas = new ArrayList<Regla>();
        BufferedReader lector = new BufferedReader(new FileReader(ruta));
        String linea;
        int numeroLinea = 0;

        while ((linea = lector.readLine()) != null) {
            numeroLinea++;
            linea = linea.trim();

            if (linea.isEmpty() || linea.startsWith("#")) {
                continue;
            }

            Regla regla = analizarLinea(linea, numeroLinea);
            if (regla != null) {
                reglas.add(regla);
            }
        }

        lector.close();
        return reglas;
    }

    private Regla analizarLinea(String linea, int numeroLinea) {
        String[] tokens = linea.split("\\s+");

        if (tokens.length != 3) {
            errores.add("Linea " + numeroLinea + ": se esperaban 3 elementos, se encontraron "
                        + tokens.length + " en \"" + linea + "\"");
            return null;
        }

        String identificador = tokens[0];
        String operador = tokens[1];
        String textoNumero = tokens[2];

        if (!esIdentificadorValido(identificador)) {
            errores.add("Linea " + numeroLinea + ": identificador no reconocido \""
                        + identificador + "\"");
            return null;
        }

        if (!esOperadorValido(operador)) {
            errores.add("Linea " + numeroLinea + ": operador no valido \"" + operador + "\"");
            return null;
        }

        double umbral;
        try {
            umbral = Double.parseDouble(textoNumero);
        } catch (NumberFormatException e) {
            errores.add("Linea " + numeroLinea + ": se esperaba un numero, se encontro \""
                        + textoNumero + "\"");
            return null;
        }

        return construirRegla(identificador, operador, umbral);
    }

    private boolean esIdentificadorValido(String token) {
        return token.equals("TEMP_ALTA")
            || token.equals("LLUVIA_INTENSA")
            || token.equals("VIENTO_FUERTE")
            || token.equals("BATERIA_BAJA");
    }

    private boolean esOperadorValido(String token) {
        return token.equals(">") || token.equals("<")
            || token.equals(">=") || token.equals("<=");
    }

    private Regla construirRegla(String identificador, String operador, double umbral) {
        if (identificador.equals("TEMP_ALTA")) {
            return new ReglaTemperatura(identificador, operador, umbral);
        } else if (identificador.equals("LLUVIA_INTENSA")) {
            return new ReglaPrecipitacion(identificador, operador, umbral);
        } else if (identificador.equals("VIENTO_FUERTE")) {
            return new ReglaViento(identificador, operador, umbral);
        } else {
            return new ReglaBateria(identificador, operador, umbral);
        }
    }

    public List<String> getErrores() {
        return errores;
    }
}
