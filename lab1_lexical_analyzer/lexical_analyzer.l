%option noyywrap
%{
/*****************声明和选项设置  begin*****************/
#include <stdio.h>
#include <stdlib.h>

#include "lab1_lexical_analyzer/lexical_analyzer.h"
#include "common/common.h"

#ifndef LAB1_ONLY
#include "syntax_analyzer.h"
#endif

int files_count=0;
int lines=1;
int pos_start=1;
int pos_end=1;

/*****************声明和选项设置  end*****************/

%}
digit [0-9]
NUM {digit}+
letter [a-zA-Z]
ID {letter}+
blank [ \t]+
eol \n
commentPattern "/*"([^\*]|(\*)*[^\*/])*(\*)*"*/"

%%

 /******************TODO*********************/
 /****请在此补全所有flex的模式与动作  start******/
"int"    {pos_start = pos_end;pos_end = pos_start + 3;return INT;}

"void"   { pos_start = pos_end; pos_end = pos_start + 4; return VOID; }

"return" { pos_start = pos_end; pos_end = pos_start + 6; return RETURN; }

"if" { pos_start = pos_end; pos_end = pos_start + 2; return IF; }

"else" { pos_start = pos_end; pos_end = pos_start + 4; return ELSE; }

"while" { pos_start = pos_end; pos_end = pos_start + 5; return WHILE; }

"==" { pos_start = pos_end; pos_end = pos_start + 2; return EQ; }

"!=" { pos_start = pos_end; pos_end = pos_start + 2; return NEQ; }

"<" { pos_start = pos_end; pos_end = pos_start + 1; return LT; }

"<=" { pos_start = pos_end; pos_end = pos_start + 2; return LTE; }

">" { pos_start = pos_end; pos_end = pos_start + 1; return GT; }

">=" { pos_start = pos_end; pos_end = pos_start + 2; return GTE; }

"+" { pos_start = pos_end; pos_end = pos_start + 1; return ADD; }

"-" { pos_start = pos_end; pos_end = pos_start + 1; return SUB; }

"*" { pos_start = pos_end; pos_end = pos_start + 1; return MUL; }

"/" { pos_start = pos_end; pos_end = pos_start + 1; return DIV; }

"(" { pos_start = pos_end; pos_end = pos_start + 1; return LPARENTHESE; }

")"  { pos_start = pos_end; pos_end = pos_start + 1; return RPARENTHESE; }

"{"  { pos_start = pos_end; pos_end = pos_start + 1; return LBRACE; }

"}" { pos_start = pos_end; pos_end = pos_start + 1; return RBRACE; }

"[" { pos_start = pos_end; pos_end = pos_start + 1; return LBRACKET; }

"]" { pos_start = pos_end; pos_end = pos_start + 1; return RBRACKET; }

"="  { pos_start = pos_end; pos_end = pos_start + 1; return ASSIN; }

";" { pos_start = pos_end; pos_end = pos_start + 1; return SEMICOLON;  }

"," { pos_start = pos_end; pos_end = pos_start + 1; return COMMA; }

{eol} { pos_start = 1; pos_end = 1; lines++; /*return EOL;*/ }

"[]" { pos_start = pos_end; pos_end = pos_start + yyleng; return ARRAY; }

{ID}    {
    #ifndef LAB1_ONLY
    strncpy(yylval.name, strdup(yytext), strlen(yytext));
    yylval.name[strlen(yytext)] = '\0';
    //printf("identifierPattern name:  %s\n", yylval.name);
    #endif
    pos_start = pos_end;pos_end = pos_start+yyleng;
    return IDENTIFIER;
    
}

{commentPattern} { /*return COMMENT*/ }

{NUM}    {
    #ifndef LAB1_ONLY
    yylval.num = atoi(yytext);
    #endif
    pos_start = pos_end;pos_end = pos_start+yyleng;
    return NUMBER;}

{letter}    {pos_start = pos_end;pos_end = pos_start+yyleng;return LETTER;}	
{blank} { pos_start = pos_end; pos_end = pos_start + yyleng; /*return BLANK;*/ }

. { /* saw some char not in the language pos_start = pos_end; pos_end = pos_start + yyleng;  return ERROR;*/ }



 /****请在此补全所有flex的模式与动作  end******/
%%
/****************C代码 start*************/

/// \brief analysize a *.cminus file
///
///	\param input_file_name
/// \param output_file_name
void analyzer(char* input_file_name, char* output_file_name){
	lines = 1;
	pos_start = 1;
	pos_end = 1;
	char input_path[256] = "./testcase/";
	strcat(input_path, input_file_name);
	char output_path[256] = "./tokens/";
	strcat(output_path, output_file_name);
	if(!(yyin = fopen(input_path,"r"))){
		printf("[ERR] No input file\n");
		exit(1);
	}
	printf("[START]: Read from: %s\n", input_file_name);
	FILE *fp = fopen(output_path,"w+");

	int token;
	while(token = yylex()){
		//pos_start = pos_end;
		//pos_end += strlen(yytext);
		switch(token){
			case ERROR:
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				break;
			case COMMENT:
			case BLANK:
				break;
			case EOL:
				//pos_start = 1,pos_end = 1;
				break;
			case NUMBER:
				fprintf(fp, "%d\t%d\t%d\t%d\t%d\n",atoi(yytext), token, lines, pos_start, pos_end);
				break;
			default :
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n",yytext, token, lines, pos_start, pos_end);
		}
	}
	fclose(fp);
	printf("[END]: Analysis completed.\n");
}

/// \brief process all *.cminus file
///
/// note that: use relative path for all i/o operations
int lex_main(int argc, char **argv){
	char filename[10][256];
	char output_file_name[256];
	char suffix[] = ".tokens";
	files_count = getAllTestcase(filename);
	for(int i = 0; i < files_count; i++){
			int name_len = strstr(filename[i], ".cminus")-filename[i];
			strncpy(output_file_name, filename[i], name_len);
			strcpy(output_file_name+name_len, suffix);
			analyzer(filename[i],output_file_name);
	}
	return 0;
}
/****************C代码 end*************/
