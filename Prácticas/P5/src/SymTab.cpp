#include "headers/SymTab.hpp"

SymTab::SymTab() {}

// ============================================================
// EJERCICIO 2: Implementar addSym (Variables y Parámetros)
// ============================================================
bool SymTab::addSym(string id, int dir, int tipo, string cat) {
    // 1. Verificar si el id ya existe con existe(id)
    if (existe(id)) {
        return false;
    }
    // 2. Si no existe, crear un Sym(dir, tipo, cat) e insertarlo en syms[id]
    Sym nuevoSimbolo(dir, tipo, cat);
    syms[id] = nuevoSimbolo;

    // 3. Retornar true
    return true;
}

// ============================================================
// EJERCICIO 2: Implementar addSym (Funciones con vector de parámetros)
// ============================================================
bool SymTab::addSym(string id, int dir, int tipo, string cat, vector<int> params) {
    if (existe(id)) {
        return false;
    }
    Sym nuevaFuncion(dir, tipo, cat, params);
    syms[id] = nuevaFuncion;
    return true;
}

// ============================================================
// EJERCICIO 2: Implementar existe
// ============================================================
bool SymTab::existe(string id) {
    // Usar: syms.find(id) != syms.end()
    return syms.find(id) != syms.end();
}

// Obtiene la dirección de un símbolo
int SymTab::getDir(string id) {
    if (existe(id)) {
        return syms[id].dir;
    }
    cerr << "Error: símbolo '" << id << "' no encontrado." << endl;
    return -1;
}

// Obtiene el tipo de un símbolo
int SymTab::getType(string id) {
    if (existe(id)) {
        return syms[id].tipo;
    }
    cerr << "Error: símbolo '" << id << "' no encontrado." << endl;
    return -1;
}

// Obtiene la categoría de un símbolo
string SymTab::getCat(string id) {
    if (existe(id)) {
        return syms[id].cat;
    }
    return "";
}

// Retorna el mapa completo
map<string, Sym> SymTab::getSyms() {
    return syms;
}

// Imprime la tabla de símbolos
void SymTab::print() {
    cout << "========== TABLA DE SIMBOLOS ==========" << endl;
    cout << "Nombre\t\tDir\tTipo\tCat\tParams" << endl;
    cout << "------\t\t---\t----\t---\t------" << endl;
    for (auto& par : syms) {
        cout << par.first;
        if (par.first.length() < 8) cout << "\t";
        cout << "\t" << par.second.dir << "\t" << par.second.tipo << "\t" << par.second.cat << "\t";
        if (par.second.cat == "func") {
            cout << "[";
            for (size_t i = 0; i < par.second.params.size(); ++i) {
                cout << par.second.params[i];
                if (i < par.second.params.size() - 1) cout << ",";
            }
            cout << "]";
        } else {
            cout << "-";
        }
        cout << endl;
    }
    cout << "=======================================" << endl;
}
