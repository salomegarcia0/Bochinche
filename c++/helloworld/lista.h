#ifndef LISTA_H_
#pragma once 
#define LISTA_H_
#include "nodo.h"
class lista{
    private:
        nodo* pfirst;
        nodo* plast;
        int lenghtl = 0;
    public:
        lista(int f);
            
    void ingresar(int num);

    int imprimir(int i);

    int tamano();

    ~lista();
    
};
#endif 