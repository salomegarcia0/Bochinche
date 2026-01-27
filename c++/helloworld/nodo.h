#ifndef NODO_H_
#define NODO_H_
#pragma once
class nodo{

    private:
        nodo* next = nullptr;
        nodo* prev = nullptr;
        int dato;

    public: 
        nodo(int num);
    
        void ingresar_next(nodo *pnext);

        void ingresar_anterior(nodo *plast);

        nodo* dar_siguiente();

        nodo* dar_anterior();

        int dar_dato();
};

#endif 