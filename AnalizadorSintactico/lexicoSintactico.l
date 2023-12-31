%{
    /* Programa Analizador L�xico-Sint�ctico de un compilador
       Elaborado por: I�aky Ordiales Caballero
       Materia: Compiladores  ;    Grupo: 02
       Profesora: M.C. Laura Sandoval Monta�o
       Semestre: 2022-1                           
       Fecha entrega: 25 de noviembre del 2021. */


    /* OBJETIVO: 
	   Construir, en un mismo programa, los analizadores L�xico y Sint�ctico
	   Descendete Recursivo que revisen programas escritos en el lenguaje
	   definido por la gram�tica del Anexo A del documento de especificaciones.

    
    /* Breve descripci�n del programa: 
           El programa es un analizador l�xico-sint�ctico de un compilador,
	   su funci�n es la de reconocer los componentes l�xicos
	   de un lenguaje creado en la clase, generando los tokens de los
	   elementos reconocidos. Al mismo tiempo se va generado una cadena
	   de �tomos que ser�n utilizados paara realizar el an�lisis 
	   sint�ctico. 
	   Su implementaci�n est� escrita en lex/flex yacc que al
	   compilarse se transforma en c�digo en C.
	   El programa reconoce diez clases de componentes l�xicos.
	   Utiliza una gram�tica igualmente definida en clase para determinar
	   la validez de su estrucura sint�ctica a trav�s de los �tomos que
	   representan cada componente l�xico.  */
    
    /* Entradas y salidas:
	   El programa recibe un archivo de texto como argumento al 
	   llamar a ejecutar el c�digo objeo a trav�s de la consola.
	   De salida hay 6 archivos: "Tokens.txt", "TablaSimbolos.txt",
	   "TablaLiteralesCadenas.txt", "TablaLiteralesNumeros.txt", 
	   "Errores.txt", "CadenaAtomos.txt".
	   Cada archivo contiene informaci�n relevante para las
	   siguientes etapas del proceso. Y adem�s se imprimir� su
	   contenido en pantalla. La �ltima salida en pantalla ser� 
	   un mensaje indicando si el programa es correcto. */
    
    

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    // Declaraci�n funciones para an�lisis l�xico.
    int agregar(char *name);
    int busqueda(char *name);
    int catalogoReservadas(char *cadena);
    int catalogoAsignacion(char *cadena);
    int catalogoRelacion(char *cadena); 
    void impresionArchivos();

    // Declaraci�n funciones para an�lisis sint�ctico descendente recursivo.
    void errorSinta(char* datos);
    void Programa();
    void ListaD();
    void SerieF();
    void otraF();
    void D();
    void Tipo();
    void L();
    void IP();
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
    void TipoFun();

    // Declaraci�n de apuntadores a archivos utilizados.
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
    int linea=1;
    char cadenaAtomos[2048];  // Longitud m�ximo del programa a analizar = 2048 atomos, 2 kilobytes de espacio en la memoria para atomos.
    int cuentaAtomos=0;
    int cuentaSintactica=0;
    char c;

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
    
    // Compara y regresa la posici�n correspondiente para el cat�logo 
    // de operadores de asignaci�n. Usa como par�metro lo que identific� 
    // como operador de asignaci�n.
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
    
    // Compara y regresa la posici�n correspondiente para el cat�logo 
    // de operadores relacionales. Usa como par�metro lo que identific� 
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
	    cadenaAtomos[cuentaAtomos]='�';
	    cuentaAtomos++;
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
	
	printf("\n\n\n");
	ptrErrores=fopen("Errores.txt", "r");
	while ( fgets (linea, 22, ptrErrores) != NULL )
	    printf("%s", linea);
	fclose(ptrErrores);
	printf("\n");
    }


    // Aqu� empiezan funciones de ANALIZADOR SINT�CTICO

    // La funci�n imprime que hubo un error y el �tomo donde fue encontrado.
    void errorSinta(char* datos){
	cuentaErroresSinta++;
	fprintf(ptrErrores, "Error Sint�ctico, �tomo n�mero %d, con valor %c, se eperaba uno de los siguientes: '%s' \n", cuentaSintactica, c, datos);
	c=cadenaAtomos[cuentaSintactica++];
    }

    // Es la primera funci�n del analizador sint�ctico, representa a la 
    // primera producci�n de la gram�tica. Basicamente todas las funciones 
    // est�n formadas de manera similar:
    //     Habr� una funci�n por cada no terminal, y dentro de la funci�n
    //     una secci�n de c�digo por cada producci�n del no terminal.
    void Programa(){
	c=cadenaAtomos[cuentaSintactica++];

	if(c=='g' || c=='n' || c=='d' || c=='h' || c=='['){
	    ListaD();
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("[");
		return;
	    }
	    SerieF();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
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

	if(c=='g' || c=='n' || c=='d' || c=='h'){
	    Tipo();
	    L();
	    if(c==':'){
		c=cadenaAtomos[cuentaSintactica++];
		return;
	    }else{
		errorSinta(":");
		return;
	    }
	}else{
	    errorSinta("gndh");
	}
    }


    void Tipo(){

	if(c=='g' || c=='n' || c=='d' || c=='h'){
	    c=cadenaAtomos[cuentaSintactica++];
	    return;
	}else{
	    errorSinta("gndh");
	    return;
	}
    }


    void L(){

	if(c=='a'){
	    c=cadenaAtomos[cuentaSintactica++];
	    Valor();
	    IP();
	    return;
	}else{
	    errorSinta("a");
	    return;
	}
    }


    void IP(){

	if(c==','){
	    c=cadenaAtomos[cuentaSintactica++];
	    if(c=='a'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("a");
		return;
	    }
	    Valor();
	    IP();
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
	    return;
	}else{
	    errorSinta("cszr");
	    return;
	}
    }


    void A(){

	if(c=='a'){
	    c=cadenaAtomos[cuentaSintactica++];
	    AP();
	    if(c==':'){
		c=cadenaAtomos[cuentaSintactica++];
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
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("[");
		return;
	    }
	    R();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
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
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
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
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("(");
		return;
	    }
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
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
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("[");
		return;
	    }
	    R();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("(");
		return;
	    }
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
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
	    if(c=='['){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("[");
		return;
	    }
	    E();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("(");
		return;
	    }
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
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
	    E();
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c==':'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta(":");
		return;
	    }
	    return;
	}else if(c==':'){
	    c=cadenaAtomos[cuentaSintactica++];
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
	    T();
	    EP();
	    return;
	}else if(c==':' || c==']' || c==')' || c=='>' || c=='<' || c=='?' || c=='y' || c=='l' || c=='�'){
	    return;
	}else{
	    errorSinta("+-:])><?y|�");
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
	    F();
	    TP();
	    return;
	}else if(c=='+' || c=='-' || c==':' || c==']' || c==')' || c=='>' || c=='<' || c=='?' || c=='y' || c=='l' || c=='�'){
	    return;
	}else{
	    errorSinta("*/$+-");
	    return;
	}
    }


    void F(){

	if(c=='('){
	    c=cadenaAtomos[cuentaSintactica++];
	    E();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta(")");
		return;
	    }
	    return;
	}else if(c=='a' || c=='z' || c=='r'){
	    c=cadenaAtomos[cuentaSintactica++];
	    return;
	}else if(c=='['){
	    c=cadenaAtomos[cuentaSintactica++];
	    if(c=='a'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("a");
		return;
	    }
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
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

	if(c=='>' || c=='<' || c=='?' || c=='y' || c=='l' || c=='�'){
	    c=cadenaAtomos[cuentaSintactica++];
	    E();
	    return;
	}else{
	    errorSinta("><?y|�");
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
	    if(c=='a'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("a");
		return;
	    }
	    if(c==']'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("]");
		return;
	    }
	    if(c==':'){
		c=cadenaAtomos[cuentaSintactica++];
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

	if(c=='g' || c=='n' || c=='d' || c=='h' || c=='v'){
	    TipoFun();
	    if(c=='a'){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("a");
		return;
	    }
	    if(c=='('){
		c=cadenaAtomos[cuentaSintactica++];
	    }else{
		errorSinta("(");
		return;
	    }
	    ListaD();
	    S();
	    if(c==')'){
		c=cadenaAtomos[cuentaSintactica++];
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


    void TipoFun(){

	if(c=='g' || c=='n' || c=='d' || c=='h'){
	    Tipo();
	    return;
	}else if(c=='v'){
	    c=cadenaAtomos[cuentaSintactica++];
	    return;
	}else{
	    errorSinta("gndhv");
	    return;
	}
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
	      fprintf(ptrLiteralesCad, "%d %s\n", cuentaLiteralesCad, yytext);
	      cuentaLiteralesCad++;
	      cadenaAtomos[cuentaAtomos]='s';
	      cuentaAtomos++;}
{carac}      {fprintf(ptrTokens, "(9,%c)\n", yytext[1]);
	      cadenaAtomos[cuentaAtomos]='c';
	      cuentaAtomos++;}
{numFloat}   {fprintf(ptrTokens, "(7,%d)\n", cuentaLiteralesNum);
	      fprintf(ptrLiteralesNum, "%d %s\n", cuentaLiteralesNum, yytext);
	      cuentaLiteralesNum++;
	      cadenaAtomos[cuentaAtomos]='r';
	      cuentaAtomos++;}
{numInt}     {fprintf(ptrTokens, "(6,%d)\n", cuentaLiteralesNum);
	      fprintf(ptrLiteralesNum, "%d %s\n", cuentaLiteralesNum, yytext);
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
    fprintf(ptrErrores, " Errores L�xicos: \n\n");
    fclose(ptrErrores);

    ptrCadenaAtomos=fopen("CadenaAtomos.txt", "w");
    fprintf(ptrCadenaAtomos, "CADENA DE �TOMOS DEL PROGRAMA : \n\n");
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



    printf("\n ~~ El an�lisis l�xico fue realizado con �xito ~~\n\n");



    ptrErrores=fopen("Errores.txt", "a");
    fprintf(ptrErrores, "\n Errores sint�cticos: \n\n");
    Programa();
    fclose(ptrErrores);



    printf("\n ~~ El an�lisis sint�ctico fue realizado con �xito ~~\n\n\n");



    // A continuaci�n se realiza la impresi�n de la informaci�n
    // recopilada en los archivos de salida a la pantalla.
    printf("___ A continuaci�n se muestra la informaci�n recopilada de salida:\n\n");
    impresionArchivos();


    // Despues de mostrar los archivos se imprime informaci�n sobre los 
    // errores totales.
    if(cuentaErrores) {
	printf("\n~ Total de errores l�xicos = %d", cuentaErrores);
    }else {
	printf("\n~ Compilaci�n l�xica sin errores... ");
    }
    if(cuentaErroresSinta) {
	printf("\n~ Total de errores sint�cticos = %d", cuentaErroresSinta);
    }else{
	printf("\n~ Compilaci�n sint�ctica sin errores... ");
    }
    printf("\n ** Errores totales = %d\n", cuentaErrores+cuentaErroresSinta);


    // Se informa si el programa es correcto.
    if(cuentaErrores+cuentaErroresSinta){
	printf("\n\n\n    ��� EL PROGRAMA NO ES SINTACTICAMENTE CORRECTO !!!\n\n");
    }else{
	printf("\n\n\n    ��� EL PROGRAMA S� EST� SINTACTICAMENTE CORRECTO !!!\n\n");
    }

    return 0;

}
