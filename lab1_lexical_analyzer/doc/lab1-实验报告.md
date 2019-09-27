#lab1 lexical_analyzer
##PB17111637 张陶竞
实验流程<br />
**1.配置实验环境**<br />
ubuntu 16.04 LTS<br />
flex 2.6.0<br />
**2.flex语法学习**<br />
结合助教提供flex入门<br />
和网上相关资料
[https://pandolia.net/tinyc/ch8_flex.html](https://pandolia.net/tinyc/ch8_flex.html)<br />
了解本实验相关flex知识<br />
**1）**一个完整的 flex 输入文件的格式为<br />
> %{<br />
Declarations<br />
%}<br />
Definitions<br />
%%<br />
Rules<br />
%%<br />
User subroutines<br />

输入文件的第 1 段 %{ 和 %} 之间的为 声明（Declarations） ，都是 C 代码，这些代码会被原样的复制到 lex.yy.c 文件中，一般在这里声明一些全局变量和函数，这样在后面可以使用这些变量和函数。

第 2 段 %} 和 %% 之间的为 定义（Definitions），在这里可以定义正则表达式中的一些名字，可以在 规则（Rules） 段被使用。

第 3 段为 规则（Rules） 段。

第 4 段为 用户定义过程（User subroutines） 段，也都是 C 代码，本段内容会被原样复制到 yylex.c 文件的最末尾，一般在此定义第 1 段中声明的函数。

以上 4 段中，除了 Rules 段是必须要有的外，其他三个段都是可选的。

**2）**flex 规则（Rules） 段格式<br />
flex 模式文件中，%% 和 %% 之间的内容被称为 规则（rules），本文件中每一行都是一条规则，每条规则由**匹配模式（pattern)**和**事件（action)**组成， 模式在前面，用正则表达式表示，事件在后面，即 C 代码。每当一个模式被匹配到时，后面的 C 代码被执行。

**3）**flex相关函数<br />
**yyleng**给出匹配模式的长度。<br />
**yylex**扫描输入文件（默认情况下为标准输入），当扫描到一个完整的、最长的、可以和某条规则的正则表达式所匹配的字符串时，该函数会执行此规则后面的 C 代码。如果这些 C 代码中没有 return 语句，则执行完这些 C 代码后， yylex 函数会继续运行，开始下一轮的扫描和匹配。

**3.补全匹配模式（正则表达式)和事件（C代码)**<br />
阅读助教所给CMINUS简介了解该语言的特点<br />
和正则表达式相关资料
[https://www.cnblogs.com/afarmer/archive/2011/08/29/2158860.html](https://www.cnblogs.com/afarmer/archive/2011/08/29/2158860.html)<br />
了解正则表达式各符号含义和书写规则<br />

开始设计作如下定义<br />
> digit       [0-9]<br />
NUM {digit}+ //NUMBER <br />
letter      [a-zA-Z]<br />
ID  {letter}+ //IDENTIFIER<br />
blank  [ \t]+<br />
eol \n//EOL<br />
array (\[])+ //ARRAY<br />

关键字和专用符号规则形如
`"int"    {pos_start = pos_end;pos_end = pos_start + 3;return INT;}`<br />

IDENTIFIER,NUMBER,BLANK,ARRAY规则形如
`{ID} { pos_start = pos_end; pos_end = pos_start + yyleng; return IDENTIFIER; }`<br />

EOL规则如下
`{eol} { pos_start = 1; pos_end = 1; lines++; return EOL; }//pos_start和pos_end重置，行数增加`

COMMENT设计如下<br />
version1<br />
`/\*[^*]*\*+([^/*][^*]*\*+)`<br />
该正则表达式可正确匹配一至多行注释，但是无法确定行数<br />
修改如下<br />
   
   
    "/*"   { 
    pos_start = pos_end; pos_end = pos_start + 2;
    char c;
    char p = '\0';
    do{
		c = input();
        if (c == EOF) break;
        if (c == '\n') {//统计行数
			lines++; pos_start = 1; pos_end = 1;
		}
        if (p == '*' && c == '/'){//注释结束
			pos_end++;
			return COMMENT;
		}
        p = c;
        pos_end++;
       } 
    while (1); 
    }
**4）**补全getAllTestcase和main函数
`void getAllTestcase(char filename[][256])//获取testcase目录下所有*.cminus文件名,文件计数`
读取目录，strstr()匹配*.cminus文件<br />
`int main(int argc,char **argv)//获取输出文件名，调用analyzer（）`
注：每分析一个新文件pos_start,pos_end,lines需重置

时间统计

|总用时|大概5h|
|:--:|:--:|
|了解flex|45min|
|设计样例|1h|



