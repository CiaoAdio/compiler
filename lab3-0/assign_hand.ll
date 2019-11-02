; ModuleID = 'assign.c'，创建assign.c模块
;source_filename是表明这个module是从什么文件编译得到的
source_filename="assign.c"

;创建main函数,函数返回值类型为i32，对应C语言中的int，@前缀表示main函数为全局函数
;函数体由一系列基本块（BB）组成，每个BB都有一个label,label使得该BB有一个符号表入口点
define i32 @main(){
;创建BB
entry:
  ;将a赋值为1,%前缀表示a为局部变量
  %a=add i32 0,1
  ;ret用来将控制流从callee返回给caller,语法ret <type> <value>
  ret i32 %a

}
