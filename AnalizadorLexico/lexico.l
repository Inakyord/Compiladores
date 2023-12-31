%{
    /* Programa Analizador L�xico de un compilador
       Elaborado por: I�aky Ordiales Caballero
       Materia: Compiladores  ;    Grupo: 02
       Profesora: M.C. Laura Sandoval Monta�o
       Semestre: 2022-1                           
       Fecha entrega: 12 de octubre del 2021. */
    
    /* Breve descripci�n del programa: 
           El programa es el analizador l�xico de un compilador,
	   su funci�n es la de reconocer los componentes l�xicos
	   de un lenguaje creado en la clase.
	   Su implementaci�n est� escrita en lex/flex yacc que al
	   compilarse se transforma en c�digo en C.
	   El programa reconoce diez clases de componentes l�xicos. */
    
    /* Entradas y salidas:
	   El programa recibe un archivo de texto como argumento al 
	   llamar a ejecutar el c�digo objeo a trav�s de la consola.
	   De salida hay 5 archivos: "Tokens.txt", "TablaSimbolos.txt",
	   "TablaLiteralesCadenas.txt", "TablaLiteralesNumeros.txt", 
	   "Errores.txt".
	   Cada archivo contiene informaci�n relevante para las
	   siguientes etapas del proceso. */
    
    

    #include <stdio.h>
    #include <string.h>
    
    int agregar(char *name);
    int busqueda(char *name);
    int catalogoReservadas(char *cadena);
    int catalogoAsignacion(char *cadena);
    int catalogoRelacion(char *cadena); 
    void impresionArchivos();   

    FILE *ptrSimbolos;
    FILE *ptrLiteralesNum;
    FILE *ptrLiteralesCad;
    FILE *ptrTokens;
    FILE *ptrErrores;

    int cuentaSimbolos=0;
    int cuentaLiteralesNum=0;
    int cuentaLiteralesCad=0;
    int cuentaErrores=0;
    int linea=1;

    // Estructura para almacenar los s�mbolos en una lista ligada
    struct simbolo{
	struct simbolo *siguiente;
	int pos;
	char nombre[8];
	int tipo;
    };

    // Lista ligada para la tabla de s�mbolos
    struct lista{
	struct simbolo *inicio;
	struct simbolo *fin;
    };

    // variable creada de la lista de tabla de s�mbolos.
    struct lista tablaSimbolos;

    // La funci�n agregar recibe como par�metro una cadena que fue
    // reconocida por el analizador como un identificador. 
    // Usando �sta checa por ocurrencias en la lista ligada, para esto
    // llama a la funci�n busqueda. Si no hay coincidencia lo agrega a 
    // la tabla (lista ligada) y regresa su posici�n. Si ya estaba en 
    // la tabla s�lo regresa la posici�n original.
    int agregar(char *name){
	int posicion;
	if(cuentaSimbolos==0){
	    struct simbolo *nuevo;
	    nuevo = (struct simbolo*)malloc(sizeof(struct simbolo));
	    nuevo->siguiente = NULL,
	    nuevo->pos = cuentaSimbolos;
	    strcpy(nuevo->nombre, name);
	    nuevo->tipo = -1;
	    tablaSimbolos.inicio = nuevo;
	    tablaSimbolos.fin = nuevo;
	    posicion=cuentaSimbolos;
	    fprintf(ptrSimbolos, "%d %s -1\n", cuentaSimbolos, name);
	    cuentaSimbolos++;
	}else{
	    posicion=busqueda(name);
	    if(posicion==-1){
		struct simbolo *nuevo;
		nuevo = (struct simbolo*)malloc(sizeof(struct simbolo));
		nuevo->siguiente = NULL;
		nuevo->pos = cuentaSimbolos;
		strcpy(nuevo->nombre, name);
		nuevo->tipo = -1;
		tablaSimbolos.fin->siguiente = nuevo;
		tablaSimbolos.fin = nuevo;
		posicion=cuentaSimbolos;
		fprintf(ptrSimbolos, "%d %s -1\n", cuentaSimbolos, name);
		cuentaSimbolos++;
	    }
	}
	return posicion;
    }
    
    // Recorre la lista ligada y regresa la posici�n de ocurrencia.
    // Si no hay coincidencias regresa el valor -1.
    int busqueda(char *name){
	struct simbolo *aux = tablaSimbolos.inicio;
	do {
	    if(!strcmp(name, aux->nombre))
	        return aux->pos;
	    aux = aux->siguiente;
	} while (aux!=NULL);
        return -1;
    }
    
    // Compara y regresa la posici�n correspondiente para el cat�logo 
    // de palabras reservadas. Usa como par�metro lo que identific� 
    // como palabra reservada.
    int catalogoReservadas(char *cadena){
	if (!strcmp(cadena,"cadena")) {
	    return 0;
	} else if (!strcmp(cadena,"caracter")) {
	    return 1;
	} else if (!strcmp(cadena,"else")) {
	    return 2;
	} else if (!strcmp(cadena,"entero")) {
	    return 3;
	} else if (!strcmp(cadena,"for")) {
	    return 4;
	} else if (!strcmp(cadena,"if")) {
	    return 5;
	} else if (!strcmp(cadena,"real")) {
	    return 6;
	} else if (!strcmp(cadena,"return")) {
	    return 7;
	} else if (!strcmp(cadena,"void")) {
	    return 8;
	} else if (!strcmp(cadena, "while")) {
	    return 9;
	} else {
	    return -1;
	}
    }
    
    // Compara y regresa la posici�n correspondiente para el cat�logo 
    // de operadores de asignaci�n. Usa como par�metro lo que identific� 
    // como operador de asignaci�n.
    int catalogoAsignacion(char *cadena){
	if (!strcmp(cadena, "~")) {
	    return 0;
	} else if (!strcmp(cadena, "+~")) {
	    return 1;
	} else if (!strcmp(cadena, "-~")) {
	    return 2;
	} else if (!strcmp(cadena, "*~")) {
	    return 3;
	} else if (!strcmp(cadena, "/~")) {
	    return 4;
	} else if (!strcmp(cadena, "$~")) {
	    return 5;
	} else {
	    return -1;
	}
    }
    
    // Compara y regresa la posici�n correspondiente para el cat�logo 
    // de operadores relacionales. Usa como par�metro lo que identific� 
    // como operador relacional.
    int catalogoRelacion(char *cadena){
	if (!strcmp(cadena, "^^")) {
	    return 0;
	} else if (!strcmp(cadena, "^\"")) {
	    return 1;
	} else if (!strcmp(cadena, "==")) {
	    return 2;
	} else if (!strcmp(cadena, "^^=")) {
	    return 3;
	} else if (!strcmp(cadena, "^\"=")) {
	    return 4;
	} else if (!strcmp(cadena, "<>")) {
	    return 5;
	} else {
	    return -1;
	}
    }
    
    
    // Esta funci�n es necesaria para mostrar en pantalla, es decir 
    // imprimir en la consola la informaci�n recopiladda en los archivos
    // de salida. Se leen su contenido y si no est�n vac�os lo muestra
    // en pantalla. 
    void impresionArchivos(){
	char linea[22];

	ptrTokens=fopen("Tokens.txt", "r");
	while ( fgets (linea, 22, ptrTokens) != NULL )
	    printf("%s", linea);
	fclose(ptrTokens);
	
	printf("\n\n");
	if(cuentaSimbolos) {
	    ptrSimbolos=fopen("TablaSimbolos.txt", "r");
	    while ( fgets (linea, 22, ptrSimbolos) != NULL )
		printf("%s", linea);
	    fclose(ptrSimbolos);
	} else {
	    printf("NO hay elementos en la tabla de s�mbolos... \n");
	}
	
	printf("\n\n");
	if(cuentaLiteralesCad) {
	    ptrLiteralesCad=fopen("TablaLiteralesCadenas.txt", "r");
	    while ( fgets (linea, 22, ptrLiteralesCad) != NULL )
		printf("%s", linea);
	    fclose(ptrLiteralesCad);
	} else {
	    printf("NO hay elementos en la tabla de literales cadena... \n");
	}
	
	printf("\n\n");
	if(cuentaLiteralesNum) {
	    ptrLiteralesNum=fopen("TablaLiteralesNumeros.txt", "r");
	    while ( fgets (linea, 22, ptrLiteralesNum) != NULL )
		printf("%s", linea);
	    fclose(ptrLiteralesNum);
	} else {
	    printf("NO hay elementos en la tabla de literales num�ricas... \n");
	}
	
	printf("\n\n");
	ptrErrores=fopen("Errores.txt", "r");
	while ( fgets (linea, 22, ptrErrores) != NULL )
	    printf("%s", linea);
	fclose(ptrErrores);
	printf("\n");
    }

%}
reservadas (cadena)|(caracter)|(else)|(entero)|(for)|(if)|(real)|(return)|(void)|(while)
espacio [ \t\v]+
salto \n
dig [0-9]
let [A-Za-z]
ident {let}({let}|{dig}){0,5}_
opArit [\+\-\*\/\$]
opAsign {opArit}?~
especial [\(\)\{\}\[\]&,:]
opRela (^[^\"]=?)|(==)|(<>)
carac '.'
texto \"[^\"]{0,38}\"
numInt [\+\-]?{dig}{1,6}
numFloat ({dig}*\.{dig}+)|({dig}+\.{dig}*)
error .([0-9])+
%%
{reservadas} {fprintf(ptrTokens, "(0,%d)\n", catalogoReservadas(yytext));}
{ident}      {fprintf(ptrTokens, "(5,%d)\n", agregar(yytext));}
{opAsign}    {fprintf(ptrTokens, "(2,%d)\n", catalogoAsignacion(yytext));}
{opArit}     {fprintf(ptrTokens, "(1,%c)\n", yytext[0]);}
{opRela}     {fprintf(ptrTokens, "(4,%d)\n", catalogoRelacion(yytext));}
{texto}      {fprintf(ptrTokens, "(8,%d)\n", cuentaLiteralesCad);
	      fprintf(ptrLiteralesCad, "%d %s\n", cuentaLiteralesCad, yytext);
	      cuentaLiteralesCad++;}
{carac}      {fprintf(ptrTokens, "(9,%c)\n", yytext[0]);}
{numFloat}   {fprintf(ptrTokens, "(7,%d)\n", cuentaLiteralesNum);
	      fprintf(ptrLiteralesNum, "%d %s\n", cuentaLiteralesNum, yytext);
	      cuentaLiteralesNum++;}
{numInt}     {fprintf(ptrTokens, "(6,%d)\n", cuentaLiteralesNum);
	      fprintf(ptrLiteralesNum, "%d %s\n", cuentaLiteralesNum, yytext);
	      cuentaLiteralesNum++;}
{especial}   {fprintf(ptrTokens, "(3,%c)\n", yytext[0]);}
{espacio}    {;}
{salto}      {linea++;}
{error}	     {fprintf(ptrErrores, "Error Lexico, linea %d: %s no se reconoce.\n", linea, yytext);
	      cuentaErrores++;}
.            {fprintf(ptrErrores, "Error Lexico, linea %d: %s no se reconoce.\n", linea, yytext);
	      cuentaErrores++;}
%%
int main(int argc, char *argv[]) {

    yyin=fopen(argv[1], "r");

    // Titulos de archivos de salida.

    ptrSimbolos=fopen("TablaSimbolos.txt", "w");
    fprintf(ptrSimbolos, "TABLA DE SIMBOLOS : \n\n");
    fclose(ptrSimbolos);

    ptrLiteralesNum=fopen("TablaLiteralesNumeros.txt", "w");
    fprintf(ptrLiteralesNum, "TABLA DE LITERALES DE NUMEROS : \n\n");
    fclose(ptrLiteralesNum);
    
    ptrLiteralesCad=fopen("TablaLiteralesCadenas.txt", "w");
    fprintf(ptrLiteralesCad, "TABLA DE LITERALES DE CADENAS : \n\n");
    fclose(ptrLiteralesCad);

    ptrTokens=fopen("Tokens.txt", "w");
    fprintf(ptrTokens, "TOKENS : \n\n");
    fclose(ptrTokens);

    ptrErrores=fopen("Errores.txt", "w");
    fprintf(ptrErrores, "ERRORES : \n\n");
    fclose(ptrErrores);



    // Agregar datos a archivos.

    ptrSimbolos=fopen("TablaSimbolos.txt", "a");
    ptrLiteralesNum=fopen("TablaLiteralesNumeros.txt", "a");
    ptrLiteralesCad=fopen("TablaLiteralesCadenas.txt", "a");
    ptrTokens=fopen("Tokens.txt", "a");
    ptrErrores=fopen("Errores.txt", "a");

    yylex();

    fclose(ptrSimbolos);
    fclose(ptrLiteralesNum);
    fclose(ptrLiteralesCad);
    fclose(ptrTokens);
    fclose(ptrErrores);
    // Despues de cerrar el archivo imprime informaci�n sobre los 
    // errores totales.
    if(cuentaErrores) {
	fprintf(ptrErrores, "\n~ Total de errores l�xicos = %d\n", cuentaErrores);
    }else {
	fprintf(ptrErrores, "\n~ Compilaci�n l�xica sin errores... \n");
    }

    // A continuaci�n se realiza la impresi�n de la informaci�n
    // recopilada en los archivos de salida a la pantalla.
    printf("\n ~~ El an�lisis l�xico fue realizado con �xito ~~\n\n");
    impresionArchivos();

    return 0;

}
