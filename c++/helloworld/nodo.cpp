#include "nodo.h"
    nodo::nodo(int num){
            dato = num;
            next = nullptr; 
            prev = nullptr;
        }
    
    void nodo::ingresar_next(nodo *pnext){
        next = pnext;
    }

    void nodo::ingresar_anterior(nodo *plast){
        prev = plast;
    }

    nodo* nodo::dar_siguiente(){
        return next;
    }

    nodo* nodo::dar_anterior(){
        return prev;
    }

    int nodo::dar_dato(){
        return dato;
    }
