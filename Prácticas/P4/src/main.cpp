#include <iostream>
#include <string>
#include <fstream>
#include "Lexer.hpp"
#include "Parser.hpp"

using namespace std;

int main(int argc, char *argv[]) {
    if (argc < 2) {
        cerr << "Uso: ./comp <archivo>" << endl;
        return EXIT_FAILURE;
    }

    filebuf fb;
    if (!fb.open(string(argv[1]), ios::in)) {
        cerr << "Error: no se pudo abrir el archivo '" << argv[1] << "'" << endl;
        return EXIT_FAILURE;
    }

    istream in(&fb);
    C1::Lexer lexer(&in);
    C1::Parser parser(&lexer);

    cout << "Analizando archivo: " << argv[1] << endl;
    cout << "-------------------------------------------" << endl;

    int result = parser.parse();

    fb.close();

    if (result != 0) {
        cerr << "El análisis terminó con errores." << endl;
    } else {
        cout << "El análisis terminó con éxito." << endl;
    }

    return result;
}
