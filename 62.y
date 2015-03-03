%{
	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>

	int n,TypeFlag=1; 			//typeflag default to okay ie., every thing's fine
	
	#define DUMMY "Dummy"
	#define _Varlist 12
	#define _StmtList 13
	#define _Var 14
	#define _GDefList 15
	#define _Program 19
	#define _Truth 20
	#define _mod 25
	#define ARRAY 34
	#include "table2.c"
	#include "tree2.c"
	//#include "tree3.c"
	struct node* t;
	
	
%}


%union {
	int val;
	char* id;
	struct node *ptr;
}


%token <id>  ID


%token <val> INT
%token <val> WRITE READ
%token <val> IF THEN ENDIF
%token <val> WHILE DO ENDWHILE
%token <val> EQEQ
%token <val> INTEGER
%token <val> MAIN EXIT
%token <val> SILBEGIN END
%token <val> DECL ENDDECL
%token <val> GBOOL GINT INTD BOOLD
%token <val> TRUE FALSE
%token <val> LE GE NE
%token <val> AND OR NOT



%type <ptr> Program 
%type <ptr> Mainblock
%type <ptr> StmtList
%type <ptr> Stmt
%type <ptr> Relexp
%type <ptr> Expr
%type <ptr> Var
%type <ptr> Varlist
%type <ptr> GDecl
%type <ptr> GDefList
%type <ptr> GDefblock
%type <val> Truth

%left '!'
%left OR
%left AND 
%left '+' '-'
%left '*' '/' '%'
%nonassoc '<'
%nonassoc '>' LE NE GE
%nonassoc EQEQ 


%%

Program: GDefblock  Mainblock	{	
									print_table();
									if(TypeFlag==0) exit(0);
									else{
										$$=makenode($1,$2,_Program,0,DUMMY);
										evaltree($$,-1);
										print_table();
										exit(1);
									}
								}
	;

GDefblock : DECL GDefList ENDDECL	{$$=$2;}
		;

GDefList : GDefList GDecl 	{$$=makenode($1,$2,_GDefList,0,DUMMY);}

		| GDecl				{$$=$1;}

		;

GDecl   : GINT Varlist ';'	{$$=makenode($2,NULL,GINT,0,DUMMY);}		//type int
		
		| GBOOL Varlist ';' {$$=makenode($2,NULL,GBOOL,0,DUMMY);}		//type bool
		
		;

Mainblock : SILBEGIN StmtList END  	{$$ = $2;}

		;

StmtList: Stmt 			{$$=$1;}

	| StmtList Stmt 	{$$=makenode($1,$2,_StmtList,0,DUMMY);}

	;

Stmt : WRITE '(' Expr ')' ';'
	
	{$$=makenode($3,NULL,WRITE,0,DUMMY);if(type_check($$)) TypeFlag = 0;}

	| READ '(' Var ')' ';'

	{$$=makenode($3,NULL,READ,0,DUMMY);if(type_check($$)) TypeFlag = 0;}
	
	| IF '(' Relexp ')' THEN StmtList ENDIF ';'

	{$$=makenode($3,$6,IF,0,DUMMY);if(type_check($$)) TypeFlag = 0;}

	| IF '(' Var ')' THEN StmtList ENDIF ';'

	{$$=makenode($3,$6,IF,0,DUMMY);if(type_check($$)) TypeFlag = 0;}

	| WHILE '(' Relexp ')' DO StmtList ENDWHILE ';'
	
	{$$=makenode($3,$6,WHILE,0,DUMMY);if(type_check($$)) TypeFlag = 0;}

	| Var '=' Expr ';'

	{$$=makenode($1,$3,'=',0,DUMMY);if(type_check($$)) TypeFlag = 0;}

	| Var '=' Relexp ';'

	{$$=makenode($1,$3,'=',0,DUMMY);if(type_check($$)) TypeFlag = 0;}

	| INTD Varlist ';'

	{$$=makenode($2,NULL,INTD,0,DUMMY);}
	
	;

Varlist :	Varlist ',' Var  	{$$=makenode($1,$3,_Varlist,0,DUMMY);}

		| Var 					{$$=makenode(NULL,$1,_Varlist,0,DUMMY);}

		
		;

Relexp  : Expr '<' Expr    	{$$=makenode($1,$3,'<',0,DUMMY);	if(type_check($$)) TypeFlag = 0;}

		| Expr '>' Expr    	{$$=makenode($1,$3,'>',0,DUMMY);	if(type_check($$)) TypeFlag = 0;}

		| Expr GE Expr   	{$$=makenode($1,$3,GE,0,DUMMY);		if(type_check($$)) TypeFlag = 0;}

		| Expr LE Expr    	{$$=makenode($1,$3,LE,0,DUMMY);		if(type_check($$)) TypeFlag = 0;}
		
		| Expr NE Expr   	{$$=makenode($1,$3,NE,0,DUMMY);		if(type_check($$)) TypeFlag = 0;}

		| Expr EQEQ Expr   	{$$=makenode($1,$3,EQEQ,0,DUMMY);	if(type_check($$)) TypeFlag = 0;}

		| '!' Relexp  		{$$=makenode($2,NULL,NOT,0,DUMMY);	if(type_check($$)) TypeFlag = 0;}

		| Relexp AND Relexp	{$$=makenode($1,$3,AND,0,DUMMY);	if(type_check($$)) TypeFlag = 0;}

		| Relexp OR Relexp	{$$=makenode($1,$3,OR,0,DUMMY);		if(type_check($$)) TypeFlag = 0;}

		| Truth				{$$=makenode(NULL,NULL,_Truth,$1,DUMMY);}

		| '(' Relexp ')'	{$$=$2;}


		| Var 				{$$=$1;}

		;

Expr: Expr '+' Expr	{$$=makenode($1,$3,'+',0,DUMMY); if(type_check($$)) TypeFlag = 0;}

	| Expr '-' Expr	{$$=makenode($1,$3,'-',0,DUMMY); if(type_check($$)) TypeFlag = 0;}

	| Expr '*' Expr	{$$=makenode($1,$3,'*',0,DUMMY); if(type_check($$)) TypeFlag = 0;}

	| Expr '/' Expr	{$$=makenode($1,$3,'/',0,DUMMY); if(type_check($$)) TypeFlag = 0;}

	| Expr '%' Expr	{$$=makenode($1,$3,_mod,0,DUMMY);if(type_check($$)) TypeFlag = 0;}

	| INT 			{$$=makenode(NULL,NULL,INT,$1,DUMMY);}

	| Var 			{$$=$1;}

	;


Var : ID 				{$$=makenode(NULL,NULL,ID,0,$1);}

	| ID '[' Expr ']'	{$$=makenode($3,NULL,ARRAY,0,$1);}

	;

Truth : FALSE 	{$$=$1;}

		| TRUE	{$$=$1;}

		;

%%

int type_check(struct node* nd){

	//operators ----------------------------------------
	if(nd->flag=='+'||nd->flag=='-'||nd->flag=='/'||nd->flag=='*'||\
		nd->flag==_mod ||nd->flag=='>'||nd->flag=='<'||nd->flag==EQEQ||\
		nd->flag==NE||nd->flag==LE ||nd->flag==GE) {
		
		int l=1,m=1; //every thing's okay


		if(nd->left->flag==ID || nd->left->flag==ARRAY ) {
			print_table();
			struct gnode* temp=fetch(nd->left->varname);
			if(temp->type==1) l=0;
			else l=1;

		} 
		else if(nd->left->flag=='+'||nd->left->flag=='-'||nd->left->flag=='/'||\
		nd->left->flag=='*'||nd->left->flag==_mod || nd->flag==INT)	 l=1;
		else l=0;

		

		if(nd->right->flag==ID || nd->right->flag==ARRAY ) {

			struct gnode* temp=fetch(nd->right->varname);
			if(temp->type==1) m=0;
			else m=1;

		} 
		else{

			if(nd->right->flag=='+'||nd->right->flag=='-'||nd->right->flag=='/'||\
			nd->right->flag=='*'||nd->right->flag==_mod || nd->right->flag==INT) m=1;
			else m=0;

		}
		
		if(l==0 || m==0) {	//if something's wrong
			printf("Expected int but found bool in operators\n");
			//exit(1);
			return 0;			//failure : typo error
		} 
	}


	//logical connectives--------------------------------------------
	else if(nd->flag==AND ||nd->flag==OR||nd->flag==NOT){
		//
		int l=1,m=1;	//default as okay

		if(nd->left->flag==AND ||nd->left->flag==OR ||nd->left->flag==NOT ||\
		nd->left->flag=='>' ||nd->left->flag=='<' ||\
		nd->left->flag==EQEQ ||nd->left->flag==NE ||nd->left->flag==LE ||nd->left->flag==GE ) l=1;
		else l=0;

		if(nd->right &&(
			nd->right->flag==AND ||	nd->right->flag==OR ||nd->right->flag==NOT ||\
			nd->right->flag=='>' ||nd->right->flag=='<' ||\
			nd->right->flag==EQEQ ||nd->right->flag==NE ||nd->right->flag==LE ||nd->right->flag==GE )
		  ) m=1;
		else m=0;
			
		if(l==0 || m==0) {
			printf("Expected bool but found int in logic\n");
			return 0; 		//typo error
			//exit(1);
		}
		else return 1; 
		
	}


	//equality---------------------------------------------------------
	else if(nd->flag== '='){		

		struct gnode * temp= fetch(nd->left->varname);
		//if right contains a bool
		if(nd->right->flag == '>' || nd->right->flag == '<' || nd->right->flag == EQEQ \
			||nd->right->flag == NE || nd->right->flag == LE || nd->right->flag == GE \
			|| nd->right->flag == OR|| nd->right->flag == AND|| nd->right->flag == NOT\
			|| nd->right->flag == _Truth){
				
				if(temp->type !=1) {	//left is an int
					printf("int = bool TYPE MISMATCH\n");
					//exit(1); ///for the time being //later add line no.
					return 0;				//failure : typo error
				}

				else return 1;
		}

		//if right is not bool
		else{	

			if(temp->type !=0) {		//left in a bool
				printf("bool = int TYPE MISMATCH\n");
				//exit(1);
				return 0;					//failure : typo error
			}

			else return 1;
			
		}
	}

	//@Read---------------------------------------------------------------- 
	else if(nd->flag==READ){
		
		struct gnode * temp= fetch(nd->left->varname);
		//if left has a ijnt
		if(temp->type==0) return 1;
		else {
			printf("bools cannot be read\n");
			return 0;
		}
	}

	//Write----------------------------------------------------------------
	else if(nd->flag==WRITE){

		if(nd->left->flag=='+'||nd->left->flag=='/'||\
			nd->left->flag=='-'||nd->left->flag=='*')
			return 1;
		else if(nd->left->flag==ID|| nd->left->flag==ARRAY) {
			struct gnode * temp= fetch(nd->left->varname);
			//if left has a bool 
			if(temp->type==1){
				printf("Bool cannot be written\n");
				return 0;
			}
		}
		else return 0;
	}

	//if conditional------------------------------------------------------
	else if(nd->flag == IF){	
		if(nd->left->flag == '>' || nd->left->flag == '<' || nd->left->flag == EQEQ \
			||nd->left->flag == NE || nd->left->flag == LE || nd->left->flag == GE \
			|| nd->left->flag == OR|| nd->left->flag == AND|| nd->left->flag == NOT\
			|| nd->left->flag == _Truth)

			return 1;
		else{
			printf("Expected RELexp in IF but found EXP\n");
			return 0;
			//exit(1);
		}
	}
	

	//end of function : type_check
}



int evaltree(struct node* nd,int i){		//infix eval
	if (nd == NULL) {	
		return 1;
	}
	//print(nd);
	if(nd->flag==INT){		//integer
		return nd->val;
	}	

	//check both sides as integer
	if (nd->flag=='+')
		return (evaltree(nd->left,i) + evaltree(nd->right,i));

	else if(nd->flag== '*')
		return (evaltree(nd->left,i) * evaltree(nd->right,i));
	
	else if(nd->flag=='/')
	 	return (evaltree(nd->left,i) / evaltree(nd->right,i));
	
	else if(nd->flag=='-')
	 	{	printf("%d - %d\n",evaltree(nd->left,i) ,evaltree(nd->right,i) );
	 		int dog= (evaltree(nd->left,i) - evaltree(nd->right,i));
	 		printf("dog = %d\n",dog);
	 		return dog;
	 	}

	else if(nd->flag==_mod)
	 	{	printf("%d mod %d\n",evaltree(nd->left,i) ,evaltree(nd->right,i) );
	 		int dog= (evaltree(nd->left,i) % evaltree(nd->right,i));
	 		printf("dog = %d\n",dog);
	 		return dog;
	 	}


	//revission needed whather to return 1/0 or t/f  time : 5:18  3/3/15 
	else if(nd->flag=='>'){
		if (evaltree(nd->left,i) > evaltree(nd->right,i)) return TRUE;
	 	else return FALSE;
	}
	else if(nd->flag=='<'){
	 	if (evaltree(nd->left,i) < evaltree(nd->right,i)) return TRUE;
	 	else return FALSE;
	}

	else if(nd->flag==EQEQ){
	 	if (evaltree(nd->left,i) == evaltree(nd->right,i)) return TRUE;
	 	else return FALSE;
	}


	//later added
	else if(nd->flag==NE){
	 	if (evaltree(nd->left,i)!=evaltree(nd->right,i)) return TRUE;
	 	else return FALSE;
	}
	else if(nd->flag==GE){
	 	if (evaltree(nd->left,i)>= evaltree(nd->right,i)) return TRUE;
	 	else return FALSE;
	}
	else if(nd->flag==LE){
	 	if (evaltree(nd->left,i) <= evaltree(nd->right,i)) return TRUE;
	 	else return FALSE;
	}



	//checking for bool (and. or .not . )
	if(nd->flag==AND){
		if (evaltree(nd->left,i) == TRUE  && evaltree(nd->right,i) == TRUE )
			{printf("both are true\n");return TRUE;}
		else return FALSE;
	}
	else if(nd->flag==OR){
		if (evaltree(nd->left,i) == FALSE  && evaltree(nd->right,i) == FALSE )
		return FALSE;
		else return TRUE;
	}
	else if(nd->flag==NOT){
	 	if (evaltree(nd->left,i) == TRUE )
		return FALSE;
		else return TRUE;
	}

	
	else if(nd->flag==_Truth){
			return nd->val;
	}


	else if(nd->flag== '='){
		int t=evaltree(nd->right,i);			
			
		if(nd->left->flag==ID)   set(nd->left->varname,t,0);

		else if(nd->left->flag==ARRAY){
			int place = evaltree(nd->left->left,i);
			set(nd->left->varname,t,place);
		}


	}
	

	else if(nd->flag==_Program){
		evaltree(nd->left,i);
		evaltree(nd->right,i);
	}

	else if(nd->flag==_GDefList){
		evaltree(nd->left,i);
		evaltree(nd->right,i);
	}
	else if(nd->flag==GINT){	//to declaration
		evaltree(nd->left,0);	//important type here

	}
	else if(nd->flag==GBOOL){	//here too----------
		evaltree(nd->left,1);	
	}

	else if(nd->flag==ID){		//getter
		//printf("test@identi : %s\n",need->varname);
		struct gnode * temp;
		temp=fetch(nd->varname);
		int num= *(temp->bind);
		return num;

	}

	else if(nd->flag==ARRAY){
		struct gnode * temp;
		int place=evaltree(nd->left,i);
		temp=fetch(nd->varname);
		int num= *(temp->bind+place);
		return num;
		
	}

	else if(nd->flag==_Varlist){
		evaltree(nd->left,i);
		
		if(nd->right->flag==ID) {
			gentry(nd->right->varname,i,1);
			return 1;
		}
		
		else if(nd->right->flag==ARRAY){
			int size=evaltree(nd->right->left,i);
			gentry(nd->right->varname,i,size);
			return 1;
		}
	}

	else if(nd->flag==INTD){
		evaltree(nd->left,0);				//type =0 for integers
				
	}
	else if(nd->flag==READ){				//alpha : need to check
		
		int temp;	
		printf("Enter a number : ");
		scanf("%d",&temp);

		if(nd->left->flag==ID)
			set(nd->left->varname,temp,0); //set
		else{
			int place = evaltree(nd->left->left,i);
			set(nd->left->varname,temp,place);
		}
		printf("reading done\n");
		
	}

	else if(nd->flag==WRITE){

		printf("printing %d\n",evaltree(nd->left,i));

	}

	else if(nd->flag==IF){	
		
		if (evaltree(nd->left,i)==TRUE) evaltree(nd->right,i);
		else return 1;
	}

	else if(nd->flag==WHILE){

		while(evaltree(nd->left,i) == TRUE){
			evaltree(nd->right,i);
		}

	}

	else if(nd->flag == _StmtList){

		evaltree(nd->left,i);
		evaltree(nd->right,i);

	}

	return 1;
}