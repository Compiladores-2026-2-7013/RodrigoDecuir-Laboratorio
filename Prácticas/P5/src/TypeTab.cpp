#include "headers/TypeTab.hpp"

// Constructor: pre-carga los tipos primitivos
TypeTab::TypeTab() {
    // Tipo 0: int (4 bytes)
    types[0] = Type("int", 4);
    // Tipo 1: float (4 bytes)
    types[1] = Type("float", 4);
    // El siguiente ID disponible es 2
    nextId = 2;
}

// Obtiene el ID de un tipo por nombre
int TypeTab::getId(string name) {
    for (auto& par : types) {
        if (par.second.name == name) {
            return par.first;
        }
    }
    return -1;  // No encontrado
}

// ============================================================
// EJERCICIO 1: Implementar addArrayType
// ============================================================
int TypeTab::addArrayType(int numElems, int tipoBase) {
    // 1. Calcular el tamaño: numElems * getTam(tipoBase)
    int tam = numElems * getTam(tipoBase);

    // 2. Crear un Type("array", tam, numElems, tipoBase)
    Type nuevoTipo("array", tam, numElems, tipoBase);

    // 3. Almacenarlo en types[nextId]
    int idAsignado = nextId;
    types[idAsignado] = nuevoTipo;

    // 4. Incrementar nextId
    nextId++;

    // 5. Retornar el ID asignado
    return idAsignado;
}

// ============================================================
// EJERCICIO 1: Implementar addStructType
// ============================================================
int TypeTab::addStructType(int tam) {
    // 1. Crear un Type("struct", tam)
    Type nuevoStruct("struct", tam);

    // 2. Almacenarlo en types[nextId]
    int idAsignado = nextId;
    types[idAsignado] = nuevoStruct;

    // 3. Incrementar nextId
    nextId++;

    // 4. Retornar el ID asignado (nextId - 1)
    return idAsignado;
}

// Obtiene el tamaño de un tipo dado su ID
int TypeTab::getTam(int id) {
    if (types.find(id) != types.end()) {
        return types[id].tam;
    }
    cerr << "Error: tipo con ID " << id << " no encontrado en tabla de tipos." << endl;
    return 0;
}

// Obtiene el nombre de un tipo dado su ID
string TypeTab::getName(int id) {
    if (types.find(id) != types.end()) {
        return types[id].name;
    }
    return "desconocido";
}

// Imprime la tabla de tipos
void TypeTab::print() {
    cout << "========== TABLA DE TIPOS ==========" << endl;
    cout << "ID\tNombre\t\tTam\tElems\tBase" << endl;
    cout << "----\t------\t\t---\t-----\t----" << endl;
    for (auto& par : types) {
        cout << par.first << "\t" << par.second.name;
        if (par.second.name.length() < 8) cout << "\t";
        cout << "\t" << par.second.tam << "\t" << par.second.numElems << "\t" << par.second.tipoBase << endl;
    }
    cout << "====================================" << endl;
}
