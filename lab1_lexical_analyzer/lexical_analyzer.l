%option noyywrap
%{
	/*****************声明和选项设置  begin*****************/
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
int files_count = 0;
int lines = 1;
int pos_start = 1;
int pos_end = 1;

enum cminus_token_type {
     ERROR = 258,

		
     ADD = 259,
     SUB = 260,//-
     MUL = 261,//*
     DIV = 262,// /

     LT = 263,//<
     LTE = 264,//<=
     GT = 265,//>
	 GTE = 266,//>=
	 EQ = 267,//==
	 NEQ = 268,//!=

	 ASSIGN = 269,// =
	 SEMICOLON = 270,//分号
	 COMMA = 271,//逗号
	 LPARENTHESE = 272,//左括号(
	 RPARENTHESE = 273,//右括号)
	 LBRACKET = 274,//[
	 RBRACKET = 275,//]
	 LBRACE = 276,//{
	 RBRACE = 277,//}

		//关键字
	 ELSE = 278,
	 IF = 279,
	 INT = 280,
	 RETURN = 281,
	 VOID = 282,
	 WHILE = 283,


	 //3标识符ID，整数，数组
	 IDENTIFIER = 284,
	 NUMBER = 285,
	 LETTER = 286,
     ARRAY = 287,
	 EOL = 288,//文字列结尾
	 COMMENT = 289,
	 BLANK = 290
       };
	/*****************end*****************/

%}


digit       [0-9]

NUM     {digit}+

letter      [a-zA-Z]

ID  {letter}+

blank  [ \t]+

eol \n





%%

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

"="  { pos_start = pos_end; pos_end = pos_start + 1; return ASSIGN; }

";" { pos_start = pos_end; pos_end = pos_start + 1; return SEMICOLON;  }

"," { pos_start = pos_end; pos_end = pos_start + 1; return COMMA; }

{eol} { pos_start = 1; pos_end = 1; lines++; return EOL; }

{ID} { pos_start = pos_end; pos_end = pos_start + yyleng; return IDENTIFIER; }
	 
{NUM} { pos_start = pos_end; pos_end = pos_start + yyleng; return NUMBER; }

"[]" { pos_start = pos_end; pos_end = pos_start + yyleng; return ARRAY; }

"/*" { pos_start = pos_end; pos_end = pos_start + 2;

	char c;

	char p = '\0';

	do

	{
		c = input();

		if (c == EOF) break;

		if (c == '\n') {
			lines++; pos_start = 1; pos_end = 1;
		}

		if (p == '*' && c == '/'){
			pos_end++;
			return COMMENT;
		}

		p = c;

		pos_end++;

	} while (1); }
	
	
{blank} { pos_start = pos_end; pos_end = pos_start + yyleng; return BLANK; }

. { /* saw some char not in the language */pos_start = pos_end; pos_end = pos_start + yyleng;  return ERROR; }
		


	/****  end******/
%%

		/****************请按需求补全C代码 start*************/

		/// \brief analysize a *.cminus file
		///
		///	\param input_file_name
		/// \param output_file_name
		/// \todo student should fill this function
      void analyzer(char* input_file_name, char* output_file_name) {
		char input_path[256] = "./testcase/";
		strcat(input_path, input_file_name);
		char output_path[256] = "./tokens/";
		strcat(output_path, output_file_name);
		if (!(yyin = fopen(input_path, "r"))) {
			printf("[ERR] No input file\n");
			exit(1);
		}
		printf("[START]: Read from: %s\n", input_file_name);
		FILE *fp = fopen(output_path, "w+");
		int token;
		while (token = yylex()) {
			switch (token) {
			case ERROR:
				fprintf(fp, "[ERR]: unable to analysize %s at %d line, from %d to %d\n", yytext, lines, pos_start, pos_end);
				break;
			case COMMENT:
				break;
			case BLANK:
				break;
			case EOL:
				break;
			default:
				fprintf(fp, "%s\t%d\t%d\t%d\t%d\n", yytext, token, lines, pos_start, pos_end);
			}
		}
		fclose(fp);
		printf("[END]: Analysis completed.\n");
	}

	/// \brief get all file paths under 'testcase' directory
	///
	/// under 'testcase' directory, there could be many *.cminus files.
	/// \todo student should fill this function
	void getAllTestcase(char filename[][256]) {
		DIR *dp;
		int i = 0;
        char suffix[] = ".cminus";
        char dirname[256]="testcase";
		struct dirent *drip;
		if((dp=opendir(dirname))==NULL)
			printf("Can't open %s\n",dirname);
		while ((drip = readdir(dp)) != NULL) {
            if(strstr(drip->d_name,suffix)){
 			   strcpy(filename[i],drip->d_name);
			   i++;
			   files_count++;
            }
         }
	     closedir(dp);
	 }

	/// \brief process all *.cminus fileassignment makes pointer from integer without a cast [-Wint-conversion]

	///
	/// note that: use relative path for all i/o operations
	///	process all *.cminus files under 'testcase' directory,
	/// then create *.tokens files under 'tokens' directory
	/// \todo student should fill this function
	int main(int argc, char **argv) {
		char filename[10][256];
		char output_file_name[256];
		char suffix[] = ".tokens";
		getAllTestcase(filename);
		for (int i = 0; i < files_count; i++) {
            lines = 1;
            pos_start = 1;
            pos_end = 1;

			printf("Please input outputfilename:");
			scanf("%s", output_file_name);
			strcat(output_file_name, suffix);
			analyzer(filename[i], output_file_name);
		}
		return 0;
	}
	/**************** end*************/

