#include <stdio.h>
#include <stdbool.h>
#include <string.h>

//// >>>DATOS IMPORTANTES<<<
////-> 0X8000 es el nodo NULL 
////-> 2 Modos: estático (0)(Array con posiciones definidas), dinámico(1)(Array con tope, las posiciones se ocupan en orden de agregado)
////-> Al cambiar de modo, se elimina el contenido del árbol
////-> El árbol empieza en [ES : 0].

////MAX_TAMANIO DEPENDE DE ÁREA DE MEMORIA (PARÁMETRO DE LA LETRA)
const int MAX_TAMANIO=100;
const int MAX_TAMANIO2=200;
///NODO DINÁMICO
typedef struct{
    short num;///2 bytes
    short izq;///2 bytes
    short der;///2 bytes
} nodoD;///TOTAL: 6 bytes


/// TIPO ÁRBOL DINÁMICO
typedef struct 
{
    char mode;///1 byte
    unsigned short tope;///2bytes
    nodoD *arregloD;////cada nodoD ocupa 6 bytes

}DTree;

/// TIPO ÁRBOL ESTÁTICO
typedef struct 
{
    short *arregloS;////cada nodoD ocupa 2 bytes (es simplemente un short)
}STree;

///EN TOTAL LA ESTRUCTURA DEL ÁRBOL ES DE TAMAÑO AREA_MEMORIA


int main()
{
    ///INICIALIZACIÓN DEL PROGRAMA
    bool modo = 0; //0 (estático) o 1 (dinámico)
    bool salir=false;
    int opcion;
    if (modo == 0) {
            // crear STree (estático)
            STree treeS;
            // Inicializar estructura
        } else if (modo == 1) {
            // Crear DTree (dinámico)
            DTree treeD;
            // Inicializar estructura
        } else {
            printf("Inválido.\n");
            salir=true;
    }
    ///---------------------------

    ////LOOP DEL PROGRAMA
    while(!salir){
        printf("Selecciona una opción:\n");
        printf("1. Cambiar modo\n");
        printf("2. Calcular altura\n");
        printf("3. Agregar nodo\n");
        printf("4. Calcular suma\n");
        printf("5. Imprimir árbol\n");
        printf("6. Detener programa\n");
        scanf("%d", &opcion);

        switch (opcion) {
            case 1:
                //CAMBIAR MODO
                if (modo==1){
                    modo=0;
                }
                else{
                    modo=1;
                }

                break;
            
            case 2:
                //CALCULAR ALTURA
                break;

            case 3:
                //AGREGAR NODO
                break; 

            case 4:
                //CALCULAR SUMA
                break;

            case 5:
                //IMPRIMIR ÁRBOL
                break;

            case 6:
                //DETENER PROGRAMA
                salir=true;
                break;

            default:
                printf("Opción inválida.\n");
        }
        
    }
    return 0;
}



////FUNCIONES DE BAJO NIVEL ÚTILES:

///---> INICIALIZAR MEMORIA : setea todas las posiciones de memoria (DENTRO DE AREA_MEMORIA) del árbol en 0x8000 

