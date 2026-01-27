#include <iostream>
#include <string>
#include <sstream>
using namespace std;

int main(){
    int x;
    int y;
    cin >> x >> y;
    int lista[x];
    string aux;
    cin.ignore();
    getline(cin, aux);
    stringstream ss(aux);
    int numero;
    for(int i = 0; i<x;i++){
        ss >> lista[i];
    };
    int buscar[y];
    for (int i = 0;i<y;i++){
        cin >> buscar[i];
    };

     
}

int resultado(int lista[],int numero){
    int indice;
    return indice;
}