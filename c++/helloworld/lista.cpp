#include "nodo.h"
#include "lista.h"

lista::lista(int f){
            pfirst = new nodo(f);
            plast = pfirst;
            lenghtl = 0;
        }

            
    void lista::ingresar(int num){
        nodo* newnodo = new nodo (num);
        nodo* aux = pfirst;
        for(int i =0; i<lenghtl;i++){
            aux = aux->dar_siguiente();
        }
        aux->ingresar_next(newnodo);
        plast = newnodo;
        lenghtl++;
    }

    int lista::imprimir(int i){
        nodo* aux = pfirst;
        for(int j = 0; j<i;j++){
            aux = aux->dar_siguiente();
        }
        return aux->dar_dato();
    }

    int lista::tamano(){
        return lenghtl;
    }

    lista::~lista(){
        nodo* actual = pfirst;
        while(actual != nullptr){
            nodo* siguiente = actual->dar_siguiente();
            delete actual;
            actual = siguiente;
        }
    }
