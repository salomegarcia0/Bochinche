#include <iostream>
#include <string>
using namespace std;

int main(){
    int veces;
    string resultados[veces];
    cin >> veces;
    for(int i = 0; i < veces; i++){
        int x;
        int y;
        int z;
        cin >> x >> y >> z;
        string resultado = ""+to_string(y);
        for(int j = y+1; j<x; j++){
            if(j%y == 0 && j % z != 0){
                resultado += " " +to_string(j);
            }
            
        } 
        resultados[i] = resultado;
    }
    for(int i = 0; i < veces; i++){
        cout << resultados[i] << "\n";
    }

    return 0;
}