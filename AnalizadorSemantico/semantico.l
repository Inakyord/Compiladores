%{
    /* Programa Analizador Léxico-Sintáctico-Semántico de un compilador
       Elaborado por: Iñaky Ordiales Caballero
       Materia: Compiladores  ;    Grupo: 02
       Profesora: M.C. Laura Sandoval Montaño
       Semestre: 2022-1                           
       Fecha entrega: 15 de diciembre del 2021. */


    /* OBJETIVO: 
	   Construir, en un mismo programa, los analizadores Léxico, Sintáctico y 
	   Semántico que revisen los aspectos de los programas escritos en el lenguaje
	   definido por la gramática elaborada en clase y que se encuentra en el 
	   Anexo A del documento de especificaciones del analizador sintáctico. */

    
    /* Breve descripción del programa: 
           El programa es un analizador léxico-sintáctico-semántico de un compilador,
	   su función es la de reconocer los componentes léxicos
	   de un lenguaje creado en la clase, generando los tokens de los
	   elementos reconocidos. Al mismo tiempo se va generado una cadena
	   de átomos que serán utilizados paara realizar el análisis 
	   sintáctico. El analizador sintáctico se encarga de revisar la estructura
	   del programa y al mismo tiempo realiza un análisis semántico para
	   actualizar la tabla de símbolos y determinar si los identificadores
	   ya fueron declarados.
	   Su implementación está escrita en lex/flex yacc que al
	   compilarse se transforma en código en C.
	   El programa reconoce diez clases de componentes léxicos.
	   Utiliza una gramática igualmente definida en clase para determinar
	   la validez de su estrucura sintáctica a través de los átomos que
	   representan cada componente léxico. Y mediante el pasar parámetros
	   en las funciones recursivas, actualiza la tabla de símbolos y
	   comprueba el estado de los identificadores (funciones o variables). */
    
    /* Entradas y salidas:
	   El programa recibe un archivo de texto como argumento al 
	   llamar a ejecutar el código objeo a través de la consola.
	   De salida hay 6 archivos: "Tokens.txt", "TablaSimbolos.txt",
	   "TablaLiteralesCadenas.txt", "TablaLiteralesNumeros.txt", 
	   "Errores.txt", "CadenaAtomos.txt".
	   Cada archivo contiene información relevante para las
	   siguientes etapas del proceso. Y además se imprimirá su
	   contenido en pantalla. La última salida en pantalla será 
	   un mensaje indicando si el programa es correcto. */
    
    

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    // Declaración funciones para análisis léxico.
    int agregar(char *name);
    int busqueda(char *name);
    int catalogoReservadas(char *cadena);
    int catalogoAsignacion(char *cadena);
    int catalogoRelacion(char *cadena); 
    void impresionArchivos();

    // Declaración funciones para análisis sintáctico descendente recursivo.
    // Actualizadas con el paso de atributos para el análisis semántico.
    void errorSinta(char* datos);
    void Programa();
    void ListaD();
    void SerieF();
    void otraF();
    void D();
    int Tipo();
    void L(int tipo);
    void IP(int tipo);
    void Valor();
    void V();
    void A();
    void AP();
    void I();
    void FP();
    void B();
    void W();
    void sintaFor();
    void sintaReturn();
    void Z();
    void E();
    void EP();
    void T();
    void TP();
    void F();
    void R();
    void RP();
    void S();
    void SP();
    void otraS();
    void Func();
    int TipoFun();

    // Declaración estructura Token y funciones para análisis semántico
    struct Token{
	int clase;
	int valor;
    };
    void errorSeman(char*, int);
    void AsignaTipo(int, int);
    int RevisaDeclara(int, int);
    struct Token getToken();
    int getValorToken();

    // Declaración de apuntadores a archivos utilizados.
    FILE *ptrSimbolos;
    FILE *ptrLiteralesNum;
    FILE *ptrLiteralesCad;
    FILE *ptrTokens;
    FILE *ptrErrores;
    FILE *ptrCadenaAtomos;

    // Variables globales
    int cuentaSimbolos=0;
    int cuentaLiteralesNum=0;
    int cuentaLiteralesCad=0;
    int cuentaErrores=0;
    int cuentaErroresSinta=0;
    int cuentaErroresSeman=0;
    int linea=1;
    char cadenaAtomos[2048];  // Longitud máximo del programa a analizar = 2048 atomos, 2 kilobytes de espacio en la memoria para atomos.
    int cuentaAtomos=0;
    int cuentaSintactica=0;
    char c;
    struct Token token;

    // Estructura para almacenar los símbolos en una lista ligada
    struct simbolo{
	struct simbolo *siguiente;
	int pos;
	char nombre[8];
	int tipo;
    };

    // Lista ligada para la tabla de símbolos
    struct lista{
	struct simbolo *inicio;
	struct simbolo *fin;
    };


    // variable creada de la lista de tabla de símbolos.
    struct lista tablaSimbolos;


    // La función agregar recibe como parámetro una cadena que fue
    // reconocida por el analizador como un identificador. 
    // Usando ésta checa por ocurrencias en la lista ligada, para esto
    // llama a la función busqueda. Si no hay coincidencia lo agrega a 
    // la tabla (lista ligada) y regresa su posición. Si ya estaba en 
    // la tabla sólo regresa la posición original.
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
	    fprintf(ptrSimbolos, "%3d %10s \t-1\n", cuentaSimbolos, name);
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
		fprintf(ptrSimbolos, "%3d %10s \t-1\n", cuentaSimbolos, name);
		cuentaSimbolos++;
	    }
	}
	return posicion;
    }
    
    // Recorre la lista ligada y regresa la posición de ocurrencia.
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
    
    // Compara y regresa la posición correspondiente para el catálogo 
    // de palabras reservadas. Usa como parámetro lo que identificó 
    // como palabra reservada.
    int catalogoReservadas(char *cadena){
	if (!strcmp(cadena,"cadena")) {
	    cadenaAtomos[cuentaAtomos]='h';
	    cuentaAtomos++;
	    return 0;
	} else if (!strcmp(cadena,"caracter")) {
	    cadenaAtomos[cuentaAtomos]='g';
	    cuentaAtomos++;
	    return 1;
	} else if (!strcmp(cadena,"else")) {
	    cadenaAtomos[cuentaAtomos]='e';
	    cuentaAtomos++;
	    return 2;
	} else if (!strcmp(cadena,"entero")) {
	    cadenaAtomos[cuentaAtomos]='n';
	    cuentaAtomos++;
	    return 3;
	} else if (!strcmp(cadena,"for")) {
	    cadenaAtomos[cuentaAtomos]='f';
	    cuentaAtomos++;
	    return 4;
	} else if (!strcmp(cadena,"if")) {
	    cadenaAtomos[cuentaAtomos]='i';
	    cuentaAtomos++;
	    return 5;
	} else if (!strcmp(cadena,"real")) {
	    cadenaAtomos[cuentaAtomos]='d';
	    cuentaAtomos++;
	    return 6;
	} else if (!strcmp(cadena,"return")) {
	    cadenaAtomos[cuentaAtomos]='b';
	    cuentaAtomos++;
	    return 7;
	} else if (!strcmp(cadena,"void")) {
	    cadenaAtomos[cuentaAtomos]='v';
	    cuentaAtomos++;
	    return 8;
	} else if (!strcmp(cadena, "while")) {
	    cadenaAtomos[cuentaAtomos]='w';
	    cuentaAtomos++;
	    return 9;
	} else {
	    return -1;
	}
    }
    
    // Compara y regresa la posición correspondiente para el catálogo 
    // de operadores de asignación. Usa como parámetro lo que identificó 
    // como operador de asignación.
    int catalogoAsignacion(char *cadena){
	if (!strcmp(cadena, "~")) {
	    cadenaAtomos[cuentaAtomos]='=';
	    cuentaAtomos++;
	    return 0;
	} else if (!strcmp(cadena, "+~")) {
	    cadenaAtomos[cuentaAtomos]='m';
	    cuentaAtomos++;
	    return 1;
	} else if (!strcmp(cadena, "-~")) {
	    cadenaAtomos[cuentaAtomos]='k';
	    cuentaAtomos++;
	    return 2;
	} else if (!strcmp(cadena, "*~")) {
	    cadenaAtomos[cuentaAtomos]='p';
	    cuentaAtomos++;
	    return 3;
	} else if (!strcmp(cadena, "/~")) {
	    cadenaAtomos[cuentaAtomos]='t';
	    cuentaAtomos++;
	    return 4;
	} else if (!strcmp(cadena, "$~")) {
	    cadenaAtomos[cuentaAtomos]='u';
	    cuentaAtomos++;
	    return 5;
	} else {
	    return -1;
	}
    }
    
    // Compara y regresa la posición correspondiente para el catálogo 
    // de operadores relacionales. Usa como parámetro lo que identificó 
    // como operador relacional.
    int catalogoRelacion(char *cadena){
	if (!strcmp(cadena, "^^")) {
	    cadenaAtomos[cuentaAtomos]='>';
	    cuentaAtomos++;
	    return 0;
	} else if (!strcmp(cadena, "^\"")) {
	    cadenaAtomos[cuentaAtomos]='<';
	    cuentaAtomos++;
	    return 1;
	} else if (!strcmp(cadena, "==")) {
	    cadenaAtomos[cuentaAtomos]='?';
	    cuentaAtomos++;
	    return 2;
	} else if (!strcmp(cadena, "^^=")) {
	    cadenaAtomos[cuentaAtomos]='y';
	    cuentaAtomos++;
	    return 3;
	} else if (!strcmp(cadena, "^\"=")) {
	    cadenaAtomos[cuentaAtomos]='l';
	    cuentaAtomos++;
	    return 4;
	} else if (!strcmp(cadena, "<>")) {
	    cadenaAtomos[cuentaAtomos]='¿';
	    cuentaAtomos++;
	    return 5;
	} else {
	    return -1;
	}
    }
    
    
    // Esta función es necesaria para mostrar en pantalla, es decir 
    // imprimir en la consola la información recopiladda en los archivos
    // de salida. Se leen su contenido y si no están vacíos lo muestra
    // en pantalla. 
    void impresionArchivos(){
	char linea[22];

	ptrTokens=fopen("Tokens.txt", "r");
	while ( fgets (linea, 22, ptrTokens) != NULL )
	    printf("%s", linea);
	fclose(ptrTokens);
	
	printf("\n\n");
	ptrCadenaAtomos=fopen("CadenaAtomos.txt", "r");
	while ( fgets(linea, 22, ptrCadenaAtomos) != NULL )
	    printf("%s", linea);
	fclose(ptrCadenaAtomos);

	printf("\n\n\n");
	if(cuentaSimbolos) {
	    ptrSimbolos=fopen("TablaSimbolos.txt", "r");
	    while ( fgets (linea, 22, ptrSimbolos) != NULL )
		printf("%s", linea);
	    fclose(ptrSimbolos);
	} else {
	    printf("NO hay elementos en la tabla de símbolos... \n");
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
	    printf("NO hay elementos en la tabla de literales numéricas... \n");
	}
	
	printf("\n\n\n");
	ptrErrores=fopen("Errores.txt", "r");
	while ( fgets (linea, 22, ptrErrores) != NULL )
	    printf("%s", linea);
	fclose(ptrErrores);
	printf("\n");
    }


    // Aquí empiezan funciones de ANALIZADOR SINTÁCTICO

    // La función imprime que hubo un error y el átomo donde fue encontrado.
    void errorSinta(char* datos){
	cuentaErroresSinta++;
	fprintf(ptrErrores, "Error Sintáctico, átomo número %d, con valor %c, se eperaba uno de los siguientes: '%s' \n", cuentaSintactica, c, datos);
	c=cadenaAtomos[cuentaSintactica++];
	token = getToken();
    }

    // Es la primera función del analizador sintáctico, representa a la 
    // primera producción de la gramática. Basicamente todas las funciones 
    // están formadas de manera similar:
    //     Habrá una función por cada no terminal, y dentro de la función
    //     una sección de código por cada producción del no terminal.
    void Programa(){
	c=cadenaAtomos[cuentaSintactica++];
	token = getToken();

	if(c=='g' || c=='n' || c=='d' || c=='h' || c=='['){
	    ListaD();
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("[");
		return;
	    }
	    SerieF();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
		return;
	   }else{
		errorSinta("]");
		return;
	   }
	}else{
	    errorSinta("g n d h [");
	    return;
	}
    }


    void ListaD(){

	if(c=='g' || c=='n' || c=='d' || c=='h'){
	    D();
	    ListaD();
	    return;
	}else if(c=='[' || c=='a' || c=='i' || c=='w' || c=='f' || c=='b'){
	    return;
	}else{
	    errorSinta("gndh[aiwfb");
	    return;
	}
    }


    void SerieF(){

	if(c=='g' || c=='n' || c=='d' || c=='h' || c=='v'){
	    Func();
	    otraF();
	    return;
	}else{
	    errorSinta("gndhv");
	    return;
	}
    }


    void otraF(){

	if(c=='g' || c=='n' || c=='d' || c=='h' || c=='v'){
	    Func();
	    otraF();
	    return;
	}else if(c==']'){
	    return;
	}else{
	    errorSinta("gndhv]");
	    return;
	}
    }


    void D(){
	int tipo;

	tipo = Tipo();
	L(tipo);
	if(c == ':'){
	    c = cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	}else{
	    errorSinta(":");
	    return;
	}
    }


    int Tipo(){
	int tipo;

	if(c=='g' || c=='n' || c=='d' || c=='h'){
	    tipo = getValorToken();
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	}else{
	    errorSinta("gndh");
	    return -1;
	}
	return tipo;
    }


    void L(int tipo){
	int pos;

	if(c=='a'){
	    pos = getValorToken();
	    c = cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	}else{
	    errorSinta("a");
	    return;
	}
	if(!RevisaDeclara(pos, 1)){
	    AsignaTipo(pos, tipo);
	}
	Valor();
	IP(tipo);
	return;
    }


    void IP(int tipo){
	int pos;

	if(c==','){
	    c = cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    if(c=='a'){
		pos = getValorToken();
		c = cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("a");
		return;
	    }
	    if(!RevisaDeclara(pos, 1)){
		AsignaTipo(pos, tipo);
	    }
	    Valor();
	    IP(tipo);
	    return;
	}else if(c==':'){
	    return;
	}else{
	    errorSinta(",:");
	    return;
	}
    }


    void Valor(){

	if(c=='='){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    V();
	    return;
	}else if(c==',' || c==':'){
	    return;
	}else{
	    errorSinta("=,");
	    return;
	}
    }


    void V(){

	if(c=='c' || c=='s' || c=='z' || c=='r'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    return;
	}else{
	    errorSinta("cszr");
	    return;
	}
    }


    void A(){
	int pos;

	if(c=='a'){
	    pos = getValorToken();
	    c = cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    RevisaDeclara(pos, 0);
	    AP();
	    if(c==':'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(":");
		return;
	    }
	}else{
	    errorSinta("a");
	    return;
	}
    }


    void AP(){

	if(c=='=' || c=='m' || c=='k' || c=='p' || c=='t' || c=='u'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    E();
	    return;
	}else{
	    errorSinta("=mkptu");
	    return;
	}
    }


    void I(){

	if(c=='i'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("[");
		return;
	    }
	    R();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("]");
		return;
	    }
	    FP();
	    return;
	}else{
	    errorSinta("i");
	    return;
	}
    }


    void FP(){

	if(c=='('){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(")");
		return;
	    }
	    B();
	    return;
	}else{
	    errorSinta("(");
	    return;
	}
    }


    void B(){

	if(c=='e'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("(");
		return;
	    }
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(")");
		return;
	    }
	    return;
	}else if(c=='[' || c=='a' || c=='i' || c=='w' || c=='f' || c=='b' || c==')'){
	    return;
	}else{
	    errorSinta("e[aiwfbc");
	    return;
	}
    }


    void W(){

	if(c=='w'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("[");
		return;
	    }
	    R();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("(");
		return;
	    }
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(")");
		return;
	    }
	    return;
	}else{
	    errorSinta("w");
	    return;
	}
    }


    void sintaFor(){

	if(c=='f'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("[");
		return;
	    }
	    E();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("(");
		return;
	    }
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(")");
		return;
	    }
	    return;
	}else{
	    errorSinta("f");
	    return;
	}
    }


    void sintaReturn(){

	if(c=='b'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    Z();
	    return;
	}else{
	    errorSinta("b");
	    return;
	}
    }


    void Z(){

	if(c=='['){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    E();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c==':'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(":");
		return;
	    }
	    return;
	}else if(c==':'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    return;
	}else{
	    errorSinta("[:");
	    return;
	}
    }


    void E(){

	if(c=='(' || c=='a' || c=='z' || c=='r' || c=='['){
	    T();
	    EP();
	    return;
	}else{
	    errorSinta("(azr[");
	    return;
	}
    }


    void EP(){

	if(c=='+' || c=='-'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    T();
	    EP();
	    return;
	}else if(c==':' || c==']' || c==')' || c=='>' || c=='<' || c=='?' || c=='y' || c=='l' || c=='¿'){
	    return;
	}else{
	    errorSinta("+-:])><?y|¿");
	    return;
	}
    }


    void T(){

	if(c=='(' || c=='a' || c=='z' || c=='r' || c=='['){
	    F();
	    TP();
	    return;
	}else{
	    errorSinta("(azr[");
	    return;
	}
    }


    void TP(){

	if(c=='*' || c=='/' || c=='$'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    F();
	    TP();
	    return;
	}else if(c=='+' || c=='-' || c==':' || c==']' || c==')' || c=='>' || c=='<' || c=='?' || c=='y' || c=='l' || c=='¿'){
	    return;
	}else{
	    errorSinta("*/$+-");
	    return;
	}
    }


    void F(){
	int pos;

	if(c=='('){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    E();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(")");
		return;
	    }
	    return;
	}else if(c=='a'){
	    pos = getValorToken();
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    RevisaDeclara(pos, 0);
	    return;
	}else if(c=='z' || c=='r'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    return;
	}else if(c=='['){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    if(c=='a'){
		pos = getValorToken();
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
		RevisaDeclara(pos, 0);
	    }else{
		errorSinta("a");
		return;
	    }
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("]");
		return;
	    }
	    return;
	}else{
	    errorSinta("(azr[");
	    return;
	}
    }


    void R(){

	if(c=='(' || c=='a' || c=='z' || c=='r' || c=='['){
	    E();
	    RP();
	    return;
	}else{
	    errorSinta("(azr[");
	    return;
	}
    }


    void RP(){

	if(c=='>' || c=='<' || c=='?' || c=='y' || c=='l' || c=='¿'){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    E();
	    return;
	}else{
	    errorSinta("><?y|¿");
	    return;
	}
    }


    void S(){

	if(c=='a' || c=='i' || c=='w' || c=='f' || c=='b' || c=='['){
	    SP();
	    otraS();
	    return;
	}else{
	    errorSinta("aiwfb[");
	    return;
	}
    }


    void SP(){
	int pos;

	if(c=='a'){
	    A();
	    return;
	}else if(c=='i'){
	    I();
	    return;
	}else if(c=='w'){
	    W();
	    return;
	}else if(c=='f'){
	    sintaFor();
	    return;
	}else if(c=='b'){
	    sintaReturn();
	    return;
	}else if(c=='['){
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    if(c=='a'){
		pos = getValorToken();
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
		RevisaDeclara(pos, 0);
	    }else{
		errorSinta("a");
		return;
	    }
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c==':'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(":");
		return;
	    }
	    return;
	}else{
	    errorSinta("aiwfb[");
	    return;
	}
    }


    void otraS(){

	if(c=='a' || c=='i' || c=='w' || c=='f' || c=='b' || c=='['){
	    SP();
	    otraS();
	    return;
	}else if(c==')'){
	    return;
	}else{
	    errorSinta("aiwfb[)");
	    return;
	}
    }


    void Func(){
	int tipo;
	int pos;

	if(c=='g' || c=='n' || c=='d' || c=='h' || c=='v'){
	    tipo = TipoFun();
	    if(c=='a'){
		pos = getValorToken();
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
		if(!RevisaDeclara(pos, 1)){
		    AsignaTipo(pos, tipo);
		}
	    }else{
		errorSinta("a");
		return;
	    }
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta("(");
		return;
	    }
	    ListaD();
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
		token = getToken();
	    }else{
		errorSinta(")");
		return;
	    }
	    return;
	}else{
	    errorSinta("gndhv");
	    return;
	}
    }


    int TipoFun(){
	int tipo;

	if(c=='g' || c=='n' || c=='d' || c=='h'){
	    tipo = Tipo();
	    return tipo;
	}else if(c=='v'){
	    tipo = getValorToken();
	    c=cadenaAtomos[cuentaSintactica++];
	    token = getToken();
	    return tipo;
	}else{
	    errorSinta("gndhv");
	    return -1;
	}
    }



    // Aquí empiezan las funciones del ANALIZADOR SEMÁNTICO

    // La función AsignaTipo representa al símbolo de acción {AT} que asigna el tipo de un 
    // identificador de la tabla de símbolos. Para actualizar la tabla de símbolos tiene
    // que escribir un archivo nuevo con la información nueva y todo lo demás. 
    void AsignaTipo(int pos, int tipo){
	FILE *ptrAux;
	int posicion;
	char str1[10], str2[10];
	char buffer[40];
	
	ptrSimbolos = fopen("TablaSimbolos.txt", "r");
	ptrAux = fopen("auxiliarSeman.txt", "w");
	fprintf(ptrAux, "TABLA DE SIMBOLOS : \n\n");

	fseek(ptrSimbolos, 22, SEEK_SET);
	while(pos){
	    fgets(buffer, 40, ptrSimbolos);
	    fprintf(ptrAux, "%s", buffer);
	    pos--;
	}
	fscanf(ptrSimbolos, "%d %s %s", &posicion, str1, str2);
	if(tipo == 1){
	    fprintf(ptrAux, "%3d %10s \t%s", posicion, str1, "caracter");
	}else if(tipo == 3){
	    fprintf(ptrAux, "%3d %10s \t%s", posicion, str1, "entero");
	}else if(tipo == 6){
	    fprintf(ptrAux, "%3d %10s \t%s", posicion, str1, "real");
	}else if(tipo == 0){
	    fprintf(ptrAux, "%3d %10s \t%s", posicion, str1, "cadena");
	}else if(tipo == 8){
	    fprintf(ptrAux, "%3d %10s \t%s", posicion, str1, "void");
	}else{
	    fprintf(ptrAux, "%3d %10s \t%s", posicion, str1, "INVALIDO");
	}

	while(fgets(buffer, 40, ptrSimbolos)!=NULL){
	    fprintf(ptrAux, "%s", buffer);
	}

	fclose(ptrSimbolos);
	fclose(ptrAux);
	remove("TablaSimbolos.txt");
	rename("auxiliarSeman.txt", "TablaSimbolos.txt");
    }


    // La función RevisaDeclara representa al símbolo de acción {RD} que revisa si para algún
    // identificador de la tabla de símbolos, ya está definido su tipo. Regresa 1 si ya está
    // declarado o 0 si sigue sin declararse. Además llama a la función de error dependiendo
    // el caso. Si se quiere hacer una declaración, pero ya está declarado es error.
    // Si se quiere utilizar, pero no está declarado es un error. El caso lo indica el 
    // parámetro declaración.
    int RevisaDeclara(int pos, int declaracion){
	int posicion;
	char str1[10], str2[10];
	char buffer[40];
	ptrSimbolos = fopen("TablaSimbolos.txt", "r");

	fseek(ptrSimbolos, 22, SEEK_SET);
	while(pos){
	    fgets(buffer, 40, ptrSimbolos);
	    pos--;
	}

	fscanf(ptrSimbolos, "%d %s %s\n", &posicion, str1, str2);
	if(strcmp(str2, "-1")){
	    if(declaracion){
		errorSeman(str1, declaracion);
	    }
	    return 1;
	}else{
	    if(!declaracion){
		errorSeman(str1, declaracion);
	    }
	}
	return 0;
    }

    // La función errorSeman imprime que hubo un error semántico, el identificador y la razón.
    void errorSeman(char *str, int declaracion){
	cuentaErroresSeman++;
	if(declaracion){
	    fprintf(ptrErrores, "Error Semántico, se trató de volver a declarar el identificador '%s' ya declarado.\n", str);
	}else{
	    fprintf(ptrErrores, "Error Semántico, se trató de utilizar la variable o función '%s' sin o antes de ser declarada.\n", str);
	}
    }

    // La funcion getToken asigna el valor del siguiente token de la lista de tokens.
    // El segundo elemento de la lista de tokens se asigna como el mismo número si es un
    // valor numérico, o como su valor ascii si es un caracter.
    struct Token getToken(){
	char car;
	int n;
	car = fgetc(ptrTokens); // Se lee: (
	if(car == '('){
	    token.clase = fgetc(ptrTokens); // Se lee y asigna la clase #
	    car = fgetc(ptrTokens); // Se lee: ,
	    car = fgetc(ptrTokens); // Se lee el valor del token
	    if(car>47 && car<58){  // Si el valor es un número se regresa y lee como número
		fseek(ptrTokens, -1, SEEK_CUR);
		fscanf(ptrTokens, "%d", &n);
	    }else{
		n = car;
	    }
	    token.valor = n;
	    car = fgetc(ptrTokens); // Se lee: )
	    car = fgetc(ptrTokens); // Se lee: \n
	}else{
	    token.clase = -1;
	    token.valor = -1;
	}
	return token;
    }

    // La función getValorToken regresa el campo valor de token actual que es una variable global.
    int getValorToken(){
	return token.valor;
    }



%}
reservadas (cadena)|(caracter)|(else)|(entero)|(for)|(if)|(real)|(return)|(void)|(while)
espacio [ \s\t\v\r]+
salto \n
dig [0-9]
let [A-Za-z]
ident {let}({let}|{dig}){0,5}_
opArit [\+\-\*\/\$]
opAsign {opArit}?~
especial [\(\)\{\}\[\]&,:]
opRela (\^[\^\"]=?)|(==)|(<>)
carac '.'
texto \"[^\"]{0,38}\"
numInt [\+\-]?{dig}{1,6}
numFloat ({dig}*\.{dig}+)|({dig}+\.{dig}*)
%%
{reservadas} {fprintf(ptrTokens, "(0,%d)\n", catalogoReservadas(yytext));}
{ident}      {fprintf(ptrTokens, "(5,%d)\n", agregar(yytext));
	      cadenaAtomos[cuentaAtomos]='a';
	      cuentaAtomos++;}
{opAsign}    {fprintf(ptrTokens, "(2,%d)\n", catalogoAsignacion(yytext));}
{opArit}     {fprintf(ptrTokens, "(1,%c)\n", yytext[0]);
	      cadenaAtomos[cuentaAtomos]=yytext[0];
	      cuentaAtomos++;}
{opRela}     {fprintf(ptrTokens, "(4,%d)\n", catalogoRelacion(yytext));}
{texto}      {fprintf(ptrTokens, "(8,%d)\n", cuentaLiteralesCad);
	      fprintf(ptrLiteralesCad, "%3d \t%s\n", cuentaLiteralesCad, yytext);
	      cuentaLiteralesCad++;
	      cadenaAtomos[cuentaAtomos]='s';
	      cuentaAtomos++;}
{carac}      {fprintf(ptrTokens, "(9,%c)\n", yytext[1]);
	      cadenaAtomos[cuentaAtomos]='c';
	      cuentaAtomos++;}
{numFloat}   {fprintf(ptrTokens, "(7,%d)\n", cuentaLiteralesNum);
	      fprintf(ptrLiteralesNum, "%3d \t%s\n", cuentaLiteralesNum, yytext);
	      cuentaLiteralesNum++;
	      cadenaAtomos[cuentaAtomos]='r';
	      cuentaAtomos++;}
{numInt}     {fprintf(ptrTokens, "(6,%d)\n", cuentaLiteralesNum);
	      fprintf(ptrLiteralesNum, "%3d \t%s\n", cuentaLiteralesNum, yytext);
	      cuentaLiteralesNum++;
	      cadenaAtomos[cuentaAtomos]='z';
	      cuentaAtomos++;}
{especial}   {fprintf(ptrTokens, "(3,%c)\n", yytext[0]);
	      cadenaAtomos[cuentaAtomos]=yytext[0];
	      cuentaAtomos++;}
{espacio}    {;}
{salto}      {linea++;}
.	     {fprintf(ptrErrores, "Error Lexico, linea %d: '%s' no se reconoce.\n", linea, yytext);
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
    fprintf(ptrErrores, " Errores Léxicos: \n\n");
    fclose(ptrErrores);

    ptrCadenaAtomos=fopen("CadenaAtomos.txt", "w");
    fprintf(ptrCadenaAtomos, "CADENA DE ÁTOMOS DEL PROGRAMA : \n\n");
    fclose(ptrCadenaAtomos);


    // Agregar datos a archivos.

    ptrSimbolos=fopen("TablaSimbolos.txt", "a");
    ptrLiteralesNum=fopen("TablaLiteralesNumeros.txt", "a");
    ptrLiteralesCad=fopen("TablaLiteralesCadenas.txt", "a");
    ptrTokens=fopen("Tokens.txt", "a");
    ptrErrores=fopen("Errores.txt", "a");
    ptrCadenaAtomos=fopen("CadenaAtomos.txt", "a");

    yylex();
    cadenaAtomos[cuentaAtomos]='\0';
    cuentaAtomos++;
    fprintf(ptrCadenaAtomos, "%s", cadenaAtomos);

    fclose(ptrSimbolos);
    fclose(ptrLiteralesNum);
    fclose(ptrLiteralesCad);
    fclose(ptrTokens);
    fclose(ptrErrores);
    fclose(ptrCadenaAtomos);



    printf("\n ~~ El análisis léxico fue realizado con éxito ~~\n\n");


    // Se abren los archivos correspondientes y se posicionan para el análisis
    // Sintáctico - Semántico.
    ptrErrores=fopen("Errores.txt", "a");
    ptrTokens=fopen("Tokens.txt", "r");
    fseek(ptrTokens, 11, SEEK_SET);
    fprintf(ptrErrores, "\n Errores sintácticos-semánticos: \n\n");
    Programa();
    fclose(ptrErrores);
    fclose(ptrTokens);



    printf("\n ~~ El análisis sintáctico-semántico fue realizado con éxito ~~\n\n\n");



    // A continuación se realiza la impresión de la información
    // recopilada en los archivos de salida a la pantalla.
    printf("___ A continuación se muestra la información recopilada de salida:\n\n");
    impresionArchivos();


    // Despues de mostrar los archivos se imprime información sobre los 
    // errores totales.
    if(cuentaErrores) {
	printf("\n~ Total de errores léxicos = %d", cuentaErrores);
    }else {
	printf("\n~ Compilación léxica sin errores... ");
    }
    if(cuentaErroresSinta) {
	printf("\n~ Total de errores sintácticos = %d", cuentaErroresSinta);
    }else{
	printf("\n~ Compilación sintáctica sin errores... ");
    }
    if(cuentaErroresSeman) {
	printf("\n~ Total de errores semánticos = %d", cuentaErroresSeman);
    }else{
	printf("\n~ Compilación semántica sin errores... ");
    }
    printf("\n ** Errores totales = %d\n", cuentaErrores+cuentaErroresSinta+cuentaErroresSeman);
    

    // Se informa si el programa es correcto.
    if(cuentaErrores){
	printf("\n\n ¡ El programa no es léxicamente correcto !");
    }
    if(cuentaErroresSinta){
	printf("\n\n ¡ El programa no es sintácticamente correcto !");
    }
    if(cuentaErroresSeman){
	printf("\n\n ¡ El programa no es semánticamente correcto !");
    }
    if(cuentaErrores+cuentaErroresSinta+cuentaErroresSeman){
	printf("\n\n\n    ¡¡¡ EL PROGRAMA NO ES CORRECTO !!!\n\n");
    }else{
	printf("\n\n\n    ¡¡¡ EL PROGRAMA SÍ ESTÁ CORRECTO !!!\n\n");
    }

    return 0;

}
