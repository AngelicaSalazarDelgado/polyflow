import java.io.FileWriter;
import java.io.IOException;

public class Prueba {
    public static void main(String[] args) throws IOException {
        System.out.println("JAVA OK");
        FileWriter escritor = new FileWriter("/mnt/c/polyflow/salida/prueba_java.txt");
        escritor.write("hola desde java\n");
        escritor.close();
    }
}
