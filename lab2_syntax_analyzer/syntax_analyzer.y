%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common/common.h"
#include "syntax_tree/SyntaxTree.h"

#include "lab1_lexical_analyzer/lexical_analyzer.h"

// external functions from lex
extern int yylex();
extern int yyparse();
extern int yyrestart();
extern FILE * yyin;

// external variables from lexical_analyzer module
extern int lines;
extern int pos_start;
extern int pos_end;
extern char * yytext;

// Global syntax tree.
SyntaxTree * gt;
struct _SyntaxTreeNode * temp;
void yyerror(const char * s);
%}

%union {
/********** TODO: Fill in this union structure *********/
  char name[100];
  int num;
  struct _SyntaxTreeNode *node;
}

/********** TODO: Your token definition here ***********/
%token<name> ERROR
%token<name> ADD 
%token<name> SUB 
%token<name> MUL
%token<name> DIV
%token<name> LT
%token<name> LTE
%token<name> GT
%token<name> GTE
%token<name> EQ
%token<name> NEQ
%token<name> ASSIN
%token<name> SEMICOLON
%token<name> COMMA
%token<name> LPARENTHESE
%token<name> RPARENTHESE
%token<name> LBRACKET
%token<name> RBRACKET
%token<name> LBRACE
%token<name> RBRACE 
%token<name> ELSE
%token<name> IF
%token<name> INT
%token<name> RETURN
%token<name> VOID
%token<name> WHILE 
%token<name> IDENTIFIER 
%token<num> NUMBER 
%token<name> ARRAY
%token<name> LETTER 
%token EOL
%token COMMENT
%token BLANK

%type<node> program
%type<node> declaration-list
%type<node> declaration
%type<node> var-declaration
%type<node> fun-declaration
%type<node> type-specifier
%type<node> params
%type<node> param-list
%type<node> param
%type<node> compound-stmt
%type<node> local-declarations
%type<node> statement-list
%type<node> statement
%type<node> expression-stmt
%type<node> selection-stmt
%type<node> iteration-stmt
%type<node> return-stmt
%type<node> expression
%type<node> var
%type<node> simple-expression
%type<node> relop
%type<node> additive-expression
%type<node> addop
%type<node> term
%type<node> mulop
%type<node> factor
%type<node> call
%type<node> args
%type<node> arg-list 

/* compulsory starting symbol */
%start program


%%
/*************** TODO: Your rules here *****************/
program : declaration-list {
            $$ = newSyntaxTreeNode("program");
            gt->root = $$;
            SyntaxTreeNode_AddChild($$, $1);};
declaration-list : declaration-list declaration {
                     $$=newSyntaxTreeNode("declaration-list");                   
                     SyntaxTreeNode_AddChild($$, $1); 
                     SyntaxTreeNode_AddChild($$, $2);}
                  | declaration {
                     $$=newSyntaxTreeNode("declaration-list"); 
                     SyntaxTreeNode_AddChild($$, $1);};
declaration : var-declaration {
                $$=newSyntaxTreeNode("declaration"); 
                SyntaxTreeNode_AddChild($$, $1);}
             | fun-declaration {
                $$=newSyntaxTreeNode("declaration"); 
                SyntaxTreeNode_AddChild($$, $1);};
var-declaration : type-specifier IDENTIFIER SEMICOLON {
                    $$=newSyntaxTreeNode("var-declaration"); 
                    SyntaxTreeNode_AddChild($$, $1); 
                    temp=newSyntaxTreeNode($2);
                    SyntaxTreeNode_AddChild($$, temp); 
                    temp=newSyntaxTreeNode(";"); 
                    SyntaxTreeNode_AddChild($$, temp);}
                | type-specifier IDENTIFIER LBRACKET NUMBER RBRACKET SEMICOLON {
                    $$=newSyntaxTreeNode("var-declaration"); 
                    SyntaxTreeNode_AddChild($$, $1); 
                    temp=newSyntaxTreeNode($2);
                    SyntaxTreeNode_AddChild($$, temp); 
                    temp=newSyntaxTreeNode("["); 
                    SyntaxTreeNode_AddChild($$, temp);
                    temp=newSyntaxTreeNodeFromNum($4); 
                    SyntaxTreeNode_AddChild($$, temp);
                    temp=newSyntaxTreeNode("]"); 
                    SyntaxTreeNode_AddChild($$, temp);
                    temp=newSyntaxTreeNode(";"); 
                    SyntaxTreeNode_AddChild($$, temp);};                    
type-specifier : INT {
                   $$=newSyntaxTreeNode("type-specifier"); 
                   temp=newSyntaxTreeNode("int");
                   SyntaxTreeNode_AddChild($$, temp);}
               | VOID {
                   $$=newSyntaxTreeNode("type-specifier"); 
                   temp=newSyntaxTreeNode("void");
                   SyntaxTreeNode_AddChild($$, temp);};
fun-declaration : type-specifier IDENTIFIER LPARENTHESE params RPARENTHESE compound-stmt {
                   $$=newSyntaxTreeNode("fun-declaration"); 
                   SyntaxTreeNode_AddChild($$, $1);
                   temp=newSyntaxTreeNode($2);
                   SyntaxTreeNode_AddChild($$, temp);
                   temp=newSyntaxTreeNode("(");
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $4);
                   temp=newSyntaxTreeNode(")");
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $6);};
params : param-list {
           $$=newSyntaxTreeNode("params");
           SyntaxTreeNode_AddChild($$, $1);}
         | VOID {
           $$=newSyntaxTreeNode("params");
           temp=newSyntaxTreeNode("void");
           SyntaxTreeNode_AddChild($$, temp);};
param-list : param-list COMMA param {
               $$=newSyntaxTreeNode("param-list");
               SyntaxTreeNode_AddChild($$, $1);
               temp=newSyntaxTreeNode(","); 
               SyntaxTreeNode_AddChild($$, temp);
               SyntaxTreeNode_AddChild($$, $3);}
            | param {
               $$=newSyntaxTreeNode("param-list");
               SyntaxTreeNode_AddChild($$, $1);};
param : type-specifier IDENTIFIER {
          $$=newSyntaxTreeNode("param");
          SyntaxTreeNode_AddChild($$, $1);
          temp=newSyntaxTreeNode($2); 
          SyntaxTreeNode_AddChild($$, temp);}
       | type-specifier IDENTIFIER ARRAY {
          $$=newSyntaxTreeNode("param");
          SyntaxTreeNode_AddChild($$, $1);
          temp=newSyntaxTreeNode($2); 
          SyntaxTreeNode_AddChild($$, temp);
          temp=newSyntaxTreeNode("[]"); 
          SyntaxTreeNode_AddChild($$, temp);};
compound-stmt : LBRACE local-declarations statement-list RBRACE {
                  $$=newSyntaxTreeNode("compound-stmt");
                  temp=newSyntaxTreeNode("{"); 
                  SyntaxTreeNode_AddChild($$, temp);
                  SyntaxTreeNode_AddChild($$, $2);
                  SyntaxTreeNode_AddChild($$, $3);
                  temp=newSyntaxTreeNode("}"); 
                  SyntaxTreeNode_AddChild($$, temp);};
local-declarations : local-declarations var-declaration {
                       $$=newSyntaxTreeNode("local-declarations");
                       SyntaxTreeNode_AddChild($$, $1);
                       SyntaxTreeNode_AddChild($$, $2);}
                   | /*empty*/ {
                       $$=newSyntaxTreeNode("local-declarations");
                       temp=newSyntaxTreeNode("epsilon");
                       SyntaxTreeNode_AddChild($$, temp);};                      
statement-list : statement-list statement {
                   $$=newSyntaxTreeNode("statement-list"); 
                   SyntaxTreeNode_AddChild($$, $1);
                   SyntaxTreeNode_AddChild($$, $2); }
               | /*empty*/ {
                   $$=newSyntaxTreeNode("statement-list");
                   temp=newSyntaxTreeNode("epsilon");
                   SyntaxTreeNode_AddChild($$, temp);};
statement : expression-stmt {
              $$=newSyntaxTreeNode("statement"); 
              SyntaxTreeNode_AddChild($$, $1);}
          | compound-stmt {
              $$=newSyntaxTreeNode("statement"); 
              SyntaxTreeNode_AddChild($$, $1);}
          | selection-stmt {
              $$=newSyntaxTreeNode("statement"); 
              SyntaxTreeNode_AddChild($$, $1);}
          | iteration-stmt {
              $$=newSyntaxTreeNode("statement"); 
              SyntaxTreeNode_AddChild($$, $1);}
          | return-stmt{
              $$=newSyntaxTreeNode("statement"); 
              SyntaxTreeNode_AddChild($$, $1);};
expression-stmt : expression SEMICOLON {
                    $$=newSyntaxTreeNode("expression-stmt"); 
                    SyntaxTreeNode_AddChild($$, $1);
                    temp=newSyntaxTreeNode(";"); 
                    SyntaxTreeNode_AddChild($$, temp);}
                | SEMICOLON {
                    $$=newSyntaxTreeNode("expression-stmt"); 
                    temp=newSyntaxTreeNode(";"); 
                    SyntaxTreeNode_AddChild($$, temp);};
selection-stmt : IF LPARENTHESE expression RPARENTHESE statement {
                   $$=newSyntaxTreeNode("selection-stmt"); 
                   temp=newSyntaxTreeNode("if"); 
                   SyntaxTreeNode_AddChild($$, temp);
                   temp=newSyntaxTreeNode("("); 
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $3);
                   temp=newSyntaxTreeNode(")"); 
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $5);}
               | IF LPARENTHESE expression RPARENTHESE statement ELSE statement {
                   $$=newSyntaxTreeNode("selection-stmt"); 
                   temp=newSyntaxTreeNode("if"); 
                   SyntaxTreeNode_AddChild($$, temp);
                   temp=newSyntaxTreeNode("("); 
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $3);
                   temp=newSyntaxTreeNode(")"); 
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $5);
                   temp=newSyntaxTreeNode("else"); 
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $7);};
iteration-stmt : WHILE LPARENTHESE expression RPARENTHESE statement {
                   $$=newSyntaxTreeNode("iteration-stmt"); 
                   temp=newSyntaxTreeNode("while"); 
                   SyntaxTreeNode_AddChild($$, temp);
                   temp=newSyntaxTreeNode("("); 
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $3);
                   temp=newSyntaxTreeNode(")"); 
                   SyntaxTreeNode_AddChild($$, temp);
                   SyntaxTreeNode_AddChild($$, $5);};
return-stmt : RETURN SEMICOLON {
                $$=newSyntaxTreeNode("return-stmt"); 
                temp=newSyntaxTreeNode("return"); 
                SyntaxTreeNode_AddChild($$, temp);
                temp=newSyntaxTreeNode(";"); 
                SyntaxTreeNode_AddChild($$, temp);}
            | RETURN expression SEMICOLON {
                $$=newSyntaxTreeNode("return-stmt"); 
                temp=newSyntaxTreeNode("return"); 
                SyntaxTreeNode_AddChild($$, temp);
                SyntaxTreeNode_AddChild($$, $2);
                temp=newSyntaxTreeNode(";"); 
                SyntaxTreeNode_AddChild($$, temp);};              
expression : var ASSIN expression {
               $$=newSyntaxTreeNode("expression"); 
               SyntaxTreeNode_AddChild($$, $1);
               temp=newSyntaxTreeNode("="); 
               SyntaxTreeNode_AddChild($$, temp);
               SyntaxTreeNode_AddChild($$, $3);}
           | simple-expression {
               $$=newSyntaxTreeNode("expression");
               SyntaxTreeNode_AddChild($$, $1);};
var : IDENTIFIER {
        $$=newSyntaxTreeNode("var");
        temp=newSyntaxTreeNode($1); 
        SyntaxTreeNode_AddChild($$, temp);} 
    | IDENTIFIER LBRACKET expression RBRACKET {
        $$=newSyntaxTreeNode("var");
        temp=newSyntaxTreeNode($1); 
        SyntaxTreeNode_AddChild($$, temp);
        temp=newSyntaxTreeNode("["); 
        SyntaxTreeNode_AddChild($$, temp);
        SyntaxTreeNode_AddChild($$, $3);
        temp=newSyntaxTreeNode("]"); 
        SyntaxTreeNode_AddChild($$, temp);};        
simple-expression : additive-expression relop additive-expression {
                      $$=newSyntaxTreeNode("simple-expression");
                      SyntaxTreeNode_AddChild($$, $1);
                      SyntaxTreeNode_AddChild($$, $2);
                      SyntaxTreeNode_AddChild($$, $3);}
                  | additive-expression {
                      $$=newSyntaxTreeNode("simple-expression");
                      SyntaxTreeNode_AddChild($$, $1);};
relop : LTE {
          $$=newSyntaxTreeNode("relop");
          temp=newSyntaxTreeNode("<="); 
          SyntaxTreeNode_AddChild($$, temp);}
      | LT {
          $$=newSyntaxTreeNode("relop");
          temp=newSyntaxTreeNode("<"); 
          SyntaxTreeNode_AddChild($$, temp);}
      | GT {
          $$=newSyntaxTreeNode("relop");
          temp=newSyntaxTreeNode(">"); 
          SyntaxTreeNode_AddChild($$, temp);}
      | GTE {
          $$=newSyntaxTreeNode("relop");
          temp=newSyntaxTreeNode(">="); 
          SyntaxTreeNode_AddChild($$, temp);}
      | EQ {
          $$=newSyntaxTreeNode("relop");
          temp=newSyntaxTreeNode("=="); 
          SyntaxTreeNode_AddChild($$, temp);}
      | NEQ {
          $$=newSyntaxTreeNode("relop");
          temp=newSyntaxTreeNode("!="); 
          SyntaxTreeNode_AddChild($$, temp);};
additive-expression : additive-expression addop term {
                        $$=newSyntaxTreeNode("additive-expression");
                        SyntaxTreeNode_AddChild($$, $1);
                        SyntaxTreeNode_AddChild($$, $2);
                        SyntaxTreeNode_AddChild($$, $3);}
                    | term {
                        $$=newSyntaxTreeNode("additive-expression");
                        SyntaxTreeNode_AddChild($$, $1);};
addop : ADD {
          $$=newSyntaxTreeNode("addop");
          temp=newSyntaxTreeNode("+"); 
          SyntaxTreeNode_AddChild($$, temp);}
      | SUB {
          $$=newSyntaxTreeNode("addop");
          temp=newSyntaxTreeNode("-"); 
          SyntaxTreeNode_AddChild($$, temp);};
term : term mulop factor {
         $$=newSyntaxTreeNode("term");
         SyntaxTreeNode_AddChild($$, $1);
         SyntaxTreeNode_AddChild($$, $2);
         SyntaxTreeNode_AddChild($$, $3);}
     | factor {
         $$=newSyntaxTreeNode("term");
         SyntaxTreeNode_AddChild($$, $1);};
mulop : MUL {
          $$=newSyntaxTreeNode("mulop");
          temp=newSyntaxTreeNode("*"); 
          SyntaxTreeNode_AddChild($$, temp);}
      | DIV {
          $$=newSyntaxTreeNode("mulop");
          temp=newSyntaxTreeNode("/"); 
          SyntaxTreeNode_AddChild($$, temp);};
factor : LPARENTHESE expression RPARENTHESE {
           $$=newSyntaxTreeNode("factor");
           temp=newSyntaxTreeNode("("); 
           SyntaxTreeNode_AddChild($$, temp);
           SyntaxTreeNode_AddChild($$, $2);    
           temp=newSyntaxTreeNode(")"); 
           SyntaxTreeNode_AddChild($$, temp);}          
       | var {
           $$=newSyntaxTreeNode("factor");
           SyntaxTreeNode_AddChild($$, $1);}
       | call {
           $$=newSyntaxTreeNode("factor");
           SyntaxTreeNode_AddChild($$, $1);}
       | NUMBER {
           $$=newSyntaxTreeNode("factor");
           temp=newSyntaxTreeNodeFromNum($1); 
           SyntaxTreeNode_AddChild($$, temp);};
call : IDENTIFIER LPARENTHESE args RPARENTHESE {
         $$=newSyntaxTreeNode("call");
         temp=newSyntaxTreeNode($1); 
         SyntaxTreeNode_AddChild($$,temp);
         temp=newSyntaxTreeNode("("); 
         SyntaxTreeNode_AddChild($$,temp);
         SyntaxTreeNode_AddChild($$,$3);
         temp=newSyntaxTreeNode(")"); 
         SyntaxTreeNode_AddChild($$,temp);};
args : arg-list { 
         $$=newSyntaxTreeNode("args");
         SyntaxTreeNode_AddChild($$,$1);}
     | /*empty*/ {
         $$=newSyntaxTreeNode("args");
         temp=newSyntaxTreeNode("epsilon");
         SyntaxTreeNode_AddChild($$,temp);};         
arg-list : arg-list COMMA expression {
             $$=newSyntaxTreeNode("arg-list");
             SyntaxTreeNode_AddChild($$,$1);
             temp=newSyntaxTreeNode(",");
             SyntaxTreeNode_AddChild($$,temp);
             SyntaxTreeNode_AddChild($$,$3);}
         | expression {
             $$=newSyntaxTreeNode("arg-list");
             SyntaxTreeNode_AddChild($$,$1);};
%%

void yyerror(const char * s)
{
	// TODO: variables in Lab1 updates only in analyze() function in lexical_analyzer.l
	//       You need to move position updates to show error output below
	fprintf(stderr, "%s:at line:%d pos_start:%d pos_end:%d syntax error for %s\n", s, lines,pos_start,pos_end, yytext);
}

/// \brief Syntax analysis from input file to output file
///
/// \param input basename of input file
/// \param output basename of output file
void syntax(const char * input, const char * output)
{
	gt = newSyntaxTree();

	char inputpath[256] = "./testcase/";
	char outputpath[256] = "./syntree/";
	strcat(inputpath, input);
	strcat(outputpath, output);

	if (!(yyin = fopen(inputpath, "r"))) {
		fprintf(stderr, "[ERR] Open input file %s failed.", inputpath);
		exit(1);
	}
	yyrestart(yyin);
	printf("[START]: Syntax analysis start for %s\n", input);
	FILE * fp = fopen(outputpath, "w+");
	if (!fp)	return;

	// yyerror() is invoked when yyparse fail. If you still want to check the return value, it's OK.
	// `while (!feof(yyin))` is not needed here. We only analyze once.
	yyparse();

	printf("[OUTPUT] Printing tree to output file %s\n", outputpath);
	printSyntaxTree(fp, gt);
	deleteSyntaxTree(gt);
	gt = 0;

	fclose(fp);
	printf("[END] Syntax analysis end for %s\n", input);
}

/// \brief starting function for testing syntax module.
///
/// Invoked in test_syntax.c
int syntax_main(int argc, char ** argv)
{
	char filename[50][256];
	char output_file_name[256];
	const char * suffix = ".syntax_tree";
	int fn = getAllTestcase(filename);
	for (int i = 0; i < fn; i++) {
			int name_len = strstr(filename[i], ".cminus") - filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			syntax(filename[i], output_file_name);
	}
	return 0;
}
