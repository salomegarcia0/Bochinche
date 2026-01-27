#include <iostream>
#include "lista.h"
using namespace std;

int main(){
    int veces;
    cin >> veces;
    int num;
    cin >> num;
    lista lista_num = lista(num);

    for(int i = 1; i <veces;i++){
        cin>> num;
        lista_num.ingresar(num);
    }
    for(int i = 0; i <=lista_num.tamano();i++){
        cout << lista_num.imprimir(i) << "\n";
    }
    return 0;
}

/*tengo que colocar en la terminal
gcc en lonmbre de los archivos cpp
mas un -o 
y el nombre de la aplicacion
luego para correrlo es un "./"+nombre de la app (esto en linux)
en windows es escribir el nombre del programa +.exe*/