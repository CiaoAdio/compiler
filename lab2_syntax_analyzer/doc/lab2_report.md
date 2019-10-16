## lab2实验报告

姓名：张陶竞

学号：PB17111637

### 实验要求

使用Bison对lab1词法分析器生成的记号进行自底向上的语法分析并生成给定格式的语法树。

### 实验设计

1.union设计：<br />
%union {<br />
  char name[100];<br />
  int num;<br />
  struct _SyntaxTreeNode *node;<br />
}<br />
词法分析器返回的token为终结符,除了COMMENT,EOL,BLANK,NUMBER,声明格式为%token\<name> TOKENNAME<br />
词法分析器返回的NUMBER声明为%token\<num> NUMBER<br />
语法分析的非终结符,为语法树的中间结点有左右孩子,声明格式为%type\<node> 非终结符（program...)<br />
COMMENT,EOL,BLANK声明格式为%token COMMENT/EOL/BLANK<br />

2.构建语法树<br />
根据C-的语法规则，确定Bison的动作，构建语法树。<br />
采用自顶向下的分析方法，对每一个产生式左边的非终结符调用newSyntaxTreeNode()新建一个父节点，若产生式右边遇到非终结符，该非终结符是由终结符归约得来，已经是一棵语法分析的子树，只要调用SyntaxTreeNode_AddChild()将该节点加入父节点之下即可；若遇到终结符调用则需先调用newSyntaxTreeNode()新建一个节点，再将该叶子节点加入父节点之下。<br />

3.对词法分析器的修改<br />
由词法分析器返回IDENTIFIER和NUMBER的值到语法分析器<br />
IDENTIFIER：<br />
在原本flex动作中加入下面两行代码：<br />
`strncpy(yylval.name, strdup(yytext), strlen(yytext));`<br />
 `yylval.name[strlen(yytext)] = '\0';`<br />
NUMBER：<br />
在原本flex动作中加入下面一行代码：<br />
`yylval.num = atoi(yytext);`<br />

### 实验结果

1、从测试样例中，选择一个样例，显示输出结果

2、针对此案例，理解生成语法树的过程，找出函数调用的先后次序，并找出对应的产生式<br />
`int main(void) {`<br />
`	return a(b(10, c()));`<br />
`}`<br />
    

\>--+ program<br />
|  >--+ declaration-list /`program → declaration-list`<br /> 
|  |  >--+ declaration /`declaration-list → declaration`<br />
|  |  |  >--+ fun-declaration /`declaration → fun-declaration`<br />
|  |  |  |  >--+ type-specifier /`fun-declaration → type-specifier ID (params) compound-stmt`<br />
|  |  |  |  |  >--* int /`type-specifier → int` <br />
|  |  |  |  >--* main /`fun-declaration → type-specifier ID (params) compound-stmt`<br />
|  |  |  |  >--* ( /`fun-declaration → type-specifier ID (params) compound-stmt`(<br />
|  |  |  |  >--+ params /`fun-declaration → type-specifier ID (params) compound-stmt`<br />
|  |  |  |  |  >--* void /`params → void`<br />
|  |  |  |  >--* ) /`fun-declaration → type-specifier ID (params) compound-stmt`<br />
|  |  |  |  >--+ compound-stmt /`fun-declaration → type-specifier ID (params) compound-stmt`<br />
|  |  |  |  |  >--* { /`compound-stmt → { local-declarations statement-list }`<br />
|  |  |  |  |  >--+ local-declarations /`compound-stmt → { local-declarations statement-list }`<br />
|  |  |  |  |  |  >--* epsilon /`local-declarations → empty` <br />
|  |  |  |  |  >--+ statement-list /`compound-stmt → { local-declarations statement-list }`<br />
|  |  |  |  |  |  >--+ statement-list /`statement-list → statement-list statement`<br />
|  |  |  |  |  |  |  >--* epsilon /`statement-list → empty`<br />
|  |  |  |  |  |  >--+ statement /`statement-list → statement-list statement`<br />
|  |  |  |  |  |  |  >--+ return-stmt /`statement → 
return-stmt`<br />
|  |  |  |  |  |  |  |  >--* return /`return-stmt → return expression ;`<br />
|  |  |  |  |  |  |  |  >--+ expression /`return-stmt → return expression ;`<br />
|  |  |  |  |  |  |  |  |  >--+ simple-expression /`expression → simple-expression`<br />
|  |  |  |  |  |  |  |  |  |  >--+ additive-expression \`simple-expression → additive-expression`<br />
|  |  |  |  |  |  |  |  |  |  |  >--+ term \`additive-expression → term`<br />
|  |  |  |  |  |  |  |  |  |  |  |  >--+ factor \`term → factor`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  >--+ call `factor → call`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* a `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* (  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ args  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ arg-list  `args → arg-list `<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ expression  `arg-list → expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ simple-expression  `expression →  simple-expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ additive-expression  `simple-expression → additive-expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ term  `additive-expression → term `<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ factor  `term → factor`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ call  `factor → call `<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* b  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* (  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ args  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ arg-list  `args → arg-list`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ arg-list  `arg-list → arg-list , expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ expression  `arg-list → arg-list , expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ simple-expression  `expression → simple-expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ additive-expression  `simple-expression → additive-expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ term  `additive-expression → term `<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ factor  `term → factor`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* 10  `factor → NUM`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* ,  `arg-list → arg-list , expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ expression  `arg-list → arg-list , expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ simple-expression  `expression → simple-expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ additive-expression  `simple-expression → additive-expression`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ term  `additive-expression → term `<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ factor  `term → factor`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ call  `factor → call`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* c  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* (  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--+ args  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* epsilon  `args → empty`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* )  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* )  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  |  |  |  |  |  |  >--* )  `call → ID ( args )`<br />
|  |  |  |  |  |  |  |  >--* ;  <br />
|  |  |  |  |  >--* }  `compound-stmt → { local-declarations statement-list }`<br />
### 实验难点

实验中遇到哪些挑战

如如何解决文法的移进规约冲突，git merge conflict如何解决，如何调试可能出现的段错误等，只要觉得在lab2上花了挺久时间的，都可以书写<br />
1.段错误<br />
error：segmentation fault(core dump)<br />
解决方法：gdb定位出错位置。<br />
输入命令：<br />
    `ulimit -c unlimited`<br />
出现段错误后输入命令：
    `gdb ./build/test_syntax core`<br />
就会显示运行到哪一行代码出现段错误。<br />
在（gdb)调试输入`bt`会进一步显示段错误是由哪一个函数引发的。<br />

### 实验总结

学习了Bison语法，生成了语法树，对自顶向下分析方法有了更深入的了解。<br />
学习了段错误的debug方法。<br />
学习了如何解决git merge conflict。<br />

### 实验反馈

10.14号更新后的实验环境就很友好了，希望助教保持！

