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
//		| '(' Relexp ')'	{$$=$2;}
	struct node* t;

%}


%union {
	int val;
	char* id;
	struct node *ptr;
}


%token <id>  ID


%token <val> INT
%token <val> WRITE 
%token <val> READ
%token <val> IF THEN ENDIF
%token <val> WHILE DO ENDWHILE
%token <val> EQEQ
%token <val> INTEGER
%token <val> MAIN EXIT
%token <val> SILBEGIN END
%token <val> DECL ENDDECL
%token <val> GBOOL GINT INTD BOOLD
%token <val> TRUE
%token <val> FALSE
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


%left OR
%left AND 
%left '!'
%left '+' '-'
%left '*' '/' '%'
%nonassoc '<'
%nonassoc '>' LE NE GE
%nonassoc EQEQ 


%%

Program: GDefblock  Mainblock	{	
									//print_table();
									if(TypeFlag==0) {printf("Exit status = failure\n");exit(0);}
									else{
										//	$$=makenode($2,NULL,_Program,0,DUMMY);
										evaltree($2,-1);
										print_table();
										exit(1);
									}
								}
	;

GDefblock : DECL GDefList ENDDECL	{$$=$2;evaltree($$);}
		;

GDefList : GDefList GDecl 	{$$=makenode($1,$2,_GDefList,0,DUMMY);}

		| GDecl				{$$=$1;}

		;

GDecl   : GINT Varlist ';'	{$$=makenode($2,NULL,GINT,0,DUMMY); }		//type int
								//evaltree($2,0);}
		
		| GBOOL Varlist ';' {$$=makenode($2,NULL,GBOOL,0,DUMMY); }		//type bool
								//evaltree($2,1);}
		
		;

Mainblock : SILBEGIN StmtList END  	{$$ = $2;}

		;

StmtList: Stmt 			{$$=$1;}

	| StmtList Stmt 	{$$=makenode($1,$2,_StmtList,0,DUMMY);}

	;

Stmt : WRITE '(' Expr ')' ';'
	
	{$$=makenode($3,NULL,WRITE,0,DUMMY);if(!type_check($$,0)==1) {printf("1\n");TypeFlag = 0;}}

	| READ '(' Var ')' ';'

	{$$=makenode($3,NULL,READ,0,DUMMY);if(!type_check($$,0)==1) {printf("2\n");TypeFlag = 0;}}
	
	| IF '(' Relexp ')' THEN StmtList ENDIF ';'

	{$$=makenode($3,$6,IF,0,DUMMY);if(!type_check($$,1)==1){ printf("3\n");TypeFlag = 0;}}


	| WHILE '(' Relexp ')' DO StmtList ENDWHILE ';'
	
	{$$=makenode($3,$6,WHILE,0,DUMMY);if(!type_check($$,1)==1) {printf("5\n");TypeFlag = 0;}}

	| Var '=' Expr ';'

	{$$=makenode($1,$3,'=',0,DUMMY);if(!type_check($$,1)==1) {printf("6\n");TypeFlag = 0;}}

	| Var '=' Relexp ';'

	{$$=makenode($1,$3,'=',0,DUMMY);if(!type_check($$,1)==1) {printf("7\n");TypeFlag = 0;}}


	
	;

Varlist :	Varlist ',' Var  	{$$=makenode($1,$3,_Varlist,0,DUMMY);}

		| Var 					{$$=makenode(NULL,$1,_Varlist,0,DUMMY);}

		
		;

Relexp  : Expr '<' Expr    	{$$=makenode($1,$3,'<',0,DUMMY);	if(!type_check($$,0)==1) {printf("8\n");TypeFlag = 0;}}

		| Expr '>' Expr    	{$$=makenode($1,$3,'>',0,DUMMY);	if(!type_check($$,0)==1) {printf("9\n");TypeFlag = 0;}}

		| Expr GE Expr   	{$$=makenode($1,$3,GE,0,DUMMY);		if(!type_check($$,0)==1) {printf("10\n");TypeFlag = 0;}}

		| Expr LE Expr    	{$$=makenode($1,$3,LE,0,DUMMY);		if(!type_check($$,0)==1) {printf("11\n");TypeFlag = 0;}}
		
		| Expr NE Expr   	{$$=makenode($1,$3,NE,0,DUMMY);		if(!type_check($$,0)==1) {printf("12\n");TypeFlag = 0;}}

		| Expr EQEQ Expr   	{$$=makenode($1,$3,EQEQ,0,DUMMY);	if(!type_check($$,0)==1) {printf("13\n");TypeFlag = 0;}}

		| '!' Relexp  		{$$=makenode($2,NULL,NOT,0,DUMMY);	if(!type_check($$,1)==1) {printf("14\n");TypeFlag = 0;}}

		| Relexp AND Relexp	{$$=makenode($1,$3,AND,0,DUMMY);	if(!type_check($$,1)==1){printf("15\n");TypeFlag = 0;}}

		| Relexp OR Relexp	{$$=makenode($1,$3,OR,0,DUMMY);		if(!type_check($$,1)==1) {printf("16\n");TypeFlag = 0;}}

		| TRUE				{$$=makenode(NULL,NULL,_Truth,TRUE,DUMMY);}

		| FALSE				{$$=makenode(NULL,NULL,_Truth,FALSE,DUMMY);}

		| Var 				{$$=$1;}

		;

Expr: Expr '+' Expr	{$$=makenode($1,$3,'+',0,DUMMY); if(!type_check($$,0)==0) TypeFlag = 0;}

	| Expr '-' Expr	{$$=makenode($1,$3,'-',0,DUMMY); if(!type_check($$,0)==0) TypeFlag = 0;}

	| Expr '*' Expr	{$$=makenode($1,$3,'*',0,DUMMY); if(!type_check($$,0)==0) TypeFlag = 0;}

	| Expr '/' Expr	{$$=makenode($1,$3,'/',0,DUMMY); if(!type_check($$,0)==0) TypeFlag = 0;}

	| Expr '%' Expr	{$$=makenode($1,$3,_mod,0,DUMMY);if(!type_check($$,0)==0) TypeFlag = 0;}

	| INT 			{$$=makenode(NULL,NULL,INT,$1,DUMMY);}

	| Var 			{$$=$1;}

	;


Var : ID 				{$$=makenode(NULL,NULL,ID,0,$1);}

	| ID '[' Expr ']'	{$$=makenode($3,NULL,ARRAY,0,$1);}

	;



%%

//version 2   incomplete
int type_check2(struct node * nd){
	if(nd == NULL) return 1;	//okay

	if(nd->flag=='+'||nd->flag=='-'||nd->flag=='/'||nd->flag=='*'||\
		nd->flag==_mod ) {
		
		//i == 0 : true  since exp has int but no  bools
		if (type_check(nd->left,0)==0 && type_check(nd->right,0) ==0){
			return 0;
		}
		else{
			//error msg

			return 1;
		}
		
	}

}



//returns type or (1 for 'okay' and 0 for 'not okay')
int type_check(struct node* nd,int i){
	if(nd == NULL) return i;

	//base case-------------------------
	if(nd->flag==ID || nd->flag==ARRAY ) {

		struct gnode* temp=fetch(nd->varname);
		
		return temp->type;

	} 
	if(nd->flag==INT) {
		if(i==0) return 0;
		else return 1;
	}

	if(nd->flag==_Truth){

		if(i==1) return 1;
		else return 0;
	}


 	//operators ----------------------------------------
 	//returns type
	if(nd->flag=='+'||nd->flag=='-'||nd->flag=='/'||nd->flag=='*'||\
		nd->flag==_mod ) {
		
		//i == 0 : true  since exp has int but no  bools
		if (type_check(nd->left,0)==0 && type_check(nd->right,0) ==0){
			return 0;
		}
		else{
			//error msg

			return 1;
		}
		
	}

	//comparators--------------------------------------------------
	//returns type
	if(nd->flag=='>'||nd->flag=='<'||nd->flag==EQEQ||\
		nd->flag==NE||nd->flag==LE ||nd->flag==GE){

		//i == 0 : true  since exp has int but no  bools
		if (type_check(nd->left,0)==0 && type_check(nd->right,0) ==0){
			return 1;
		}
		else{
			//error msg

			return 0;
		}
	}

	//logical connectives--------------------------------------------
	//returns type
	else if(nd->flag==AND ||nd->flag==OR||nd->flag==NOT){
		
		//i==1 :
		if (type_check(nd->left,1)==1 &&  type_check(nd->right,1)==1 ) 
			return 1;
		else return 0;
	
	}


	//assignment---------------------------------------------------------
	else if(nd->flag== '='){			//i value not considered in te call

		if((type_check(nd->left,0)==type_check(nd->right,0)) ||\
			(type_check(nd->left,1)==type_check(nd->right,1))){
			return 1;	//okay
		}
		else{	
			printf("TYPE MISMATCH\n");
			return 0;	//not okaay
		}
	}

	//@Read---------------------------------------------------------------- 
	//read only int
	else if(nd->flag==READ){
		
		struct gnode * temp= fetch(nd->left->varname);
		
		//if left has a ijnt
		if(temp->type==0) {return 1;} 	//okay
		else {
			printf("bools cannot be read\n");
			return 0;
		}

	}

	//Write----------------------------------------------------------------
	//write only int
	else if(nd->flag==WRITE){

		if(type_check(nd->left,i)==0) return 1;	//okay
		else return 0;							//not okay
	}

	//if conditional------------------------------------------------------
	else if(nd->flag == IF){	
		
		if(type_check(nd->left,1)==1) return 1; //okay
		else{
			return 0;							//not okay
		}
	}
	
	//while------------------------------------------------------------
	else if(nd->flag == WHILE){

		if(type_check(nd->left,1)==1) return 1;
		else {
			//error msg
			return 0;
		}
	}
	//end of function : type_check
}



int evaltree(struct node* nd,int i){		//infix eval
	//printf("Evaluation\n");
	if (nd == NULL) {	
		return 1;
	}
	//print(nd);/
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
			{;return TRUE;}
		else return FALSE;
	}
	else if(nd->flag==OR){
		if (evaltree(nd->left,i) == FALSE  && evaltree(nd->right,i) == FALSE )
		return FALSE;
		else return TRUE;
	}
	else if(nd->flag==NOT){
	 	if (evaltree(nd->left,i) == TRUE )  return FALSE;
		else return TRUE;
	}

	
	else if(nd->flag==_Truth){
		//printf("Asked for %d\n",nd->val);
			return nd->val;
	}


	else if(nd->flag== '='){
		int t=evaltree(nd->right,i);
			//printf("Doggie kruger %d",nd->right->flag);
			//printf("changer  %d\n",t);			
			//printf("found to change : %s\n",nd->left->varname);
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