<p align="center">
  <img width="200" src="https://www.fciencias.unam.mx/sites/default/files/logoFC_2.png" alt=""> <br>
  Compiladores 2026-2 <br>
  Práctica 5: Tabla de tipos y tabla de símbolos <br>
  Profesora: Ariel Adara Mercado Martínez
</p>

### Objetivos

- Implementar una **tabla de tipos** (`TypeTab`) capaz de almacenar tipos primitivos, arreglos y estructuras (registros).
- Implementar una **pila de tablas de símbolos** (`PilaTs`) que permita manejar alcances (scopes) durante el análisis semántico.
- Integrar las reglas semánticas de declaración de variables en un esquema de traducción dirigido por la sintaxis (ETDS) utilizando Flex y Bison.
- Comprender cómo se llena la tabla de tipos y la pila de tablas de símbolos durante la declaración de variables, tipos arreglo y tipos registro (struct).

### Introducción

En esta práctica trabajaremos con la fase de **análisis semántico** del compilador, específicamente con la parte que se encarga de procesar las declaraciones de variables. Para ello necesitamos dos estructuras de datos fundamentales:

1. **Tabla de Tipos (`TypeTab`)**: Almacena información sobre cada tipo del lenguaje (nombre, tamaño en bytes, y para tipos compuestos, información adicional como el tipo base y número de elementos para arreglos, o la tabla de símbolos para registros/structs).

2. **Pila de Tablas de Símbolos (`PilaTs`)**: Una pila de tablas de símbolos que permite manejar los distintos alcances (scopes) del programa. Cada vez que se entra a un nuevo alcance (función, struct), se empuja una nueva tabla; al salir, se retira.

<details>
  <summary>Haz click para ver las reglas semánticas</summary>

#### Producción `P → D`
```
dir ← 0
PilaTs.push(nuevaTs())
```

#### Producción `D → T L ; D`
```
L.tipo = T.tipo
```

#### Producción `D → def T id ( F ) { S } D`
```
Si !PilaTs.bottom().existe(id):
    PilaTs.push(nuevaTs())
    PilaDir.push(dir)
    dir ← 0
    tipoReturnFunc ← T.tipo
    label(id)
    <ejecutar S>
    PilaTs.pop()
    dir ← PilaDir.pop()
    PilaTs.bottom().add(id, -1, T.tipo, "func", F.lista)
Sino:
    error("El id ya fue declarado anteriormente")
```

#### Producción `D → ε`
*(sin acción)*

#### Producción `T → B A`
```
A.base = B.tipo
T.tipo = A.tipo
```

#### Producción `T → register { D }`
```
PilaTs.push(nuevaTs())
PilaDir.push(dir)
dir ← 0
<procesar D>
tam_struct = dir
ts* = PilaTs.pop()
T.tipo = tablaTipos.add("struct", tam_struct)
dir ← PilaDir.pop()
```

#### Producción `B → int`
```
B.tipo = tablaTipos.getId("int")
```

#### Producción `B → float`
```
B.tipo = tablaTipos.getId("float")
```

#### Producción `A → [ num ] A₁`
```
Si num.val > 0:
    A₁.base = A.base
    A.tipo = tablaTipos.addArrayType(num.val, A₁.tipo)
Sino:
    error("El índice debe ser mayor a cero")
```

#### Producción `A → ε`
```
A.tipo = A.base
```

#### Producción `L → L₁ , id`
```
L₁.tipo = L.tipo
Si !PilaTs.top().existe(id):
    PilaTs.top().add(id, dir, L.tipo, "var")
    dir ← dir + tablaTipos.getTam(L.tipo)
Sino:
    error("La variable ya fue declarada")
```

#### Producción `L → id`
```
Si !PilaTs.top().existe(id):
    PilaTs.top().add(id, dir, L.tipo, "var")
    dir ← dir + tablaTipos.getTam(L.tipo)
Sino:
    error("La variable ya fue declarada")
```

</details>

### Estructura del directorio

```
P5/
├── README.md
└── src/
    ├── headers/
    │   ├── Attributes.hpp      ← Estructura de atributos para no-terminales
    │   ├── Lexer.hpp           ← Clase Lexer (interfaz C++ de Flex)
    │   ├── PilaTs.hpp          ← Pila de tablas de símbolos
    │   ├── SymTab.hpp          ← Tabla de símbolos individual
    │   └── TypeTab.hpp         ← Tabla de tipos
    ├── TypeTab.cpp             ← Implementación de la tabla de tipos
    ├── SymTab.cpp              ← Implementación de la tabla de símbolos
    ├── PilaTs.cpp              ← Implementación de la pila de tablas de símbolos
    ├── lexer.ll                ← Especificación Flex del analizador léxico
    ├── parser.yy               ← Especificación Bison con acciones semánticas
    ├── main.cpp                ← Punto de entrada
    ├── Makefile                ← Archivo de compilación
    └── prueba                  ← Archivo de prueba
```

### Uso

#### Compilación
```bash
cd src
make
```

#### Ejecución
```bash
./comp prueba
```

#### Limpieza
```bash
make clean
```

### Ejercicios

1. **Completar `TypeTab`**: Implementar los métodos `addArrayType` y `addStructType` en `TypeTab.cpp` para registrar tipos arreglo y tipos registro en la tabla de tipos.

2. **Completar `SymTab`**: Implementar los métodos `addSym` y `existe` en `SymTab.cpp` para agregar símbolos a la tabla y verificar su existencia.

3. **Completar las acciones semánticas en `parser.yy`**: Implementar las reglas semánticas para las producciones:
   - `P → D` (inicializar `dir ← 0`)
   - `D → T L ; D` (propagar `L.tipo = T.tipo`)
   - `D → def T id ( F ) { S } D` (declarar función: verificar en alcance global, push/pop de tabla y `dir`)
   - `T → B A` (construir tipo compuesto)
   - `T → register { D }` (crear tipo struct)
   - `B → int | float` (obtener id del tipo base)
   - `A → [ num ] A` (crear tipo arreglo)
   - `A → ε` (tipo base)
   - `F → T id , F | T id | ε` (lista de parámetros formales)
   - `L → L , id` (declarar variable en lista)
   - `L → id` (declarar variable individual)

4. **Pruebas**: Crear archivos de prueba adicionales que verifiquen:
   - Declaración de variables simples (`int a, b, c;`)
   - Declaración de arreglos (`int[5] arr;`)
   - Declaración de registros (`register { int x; float y; } punto;`)
   - Detección de error por variable duplicada
   - Cálculo correcto de direcciones de memoria (`dir`)

5. **Imprimir resultados**: Al finalizar el análisis, imprimir el contenido de la tabla de tipos y de la tabla de símbolos global para verificar que las reglas semánticas se aplicaron correctamente.
