; ModuleID = 'if.c'，创建if.c模块
;source_filename是表明这个module是从什么文件编译得到的
source_filename="if.c"

;创建main函数,函数返回值类型为i32，对应C语言中的int，@前缀表示main函数为全局函数
;函数体由一系列基本块（BB）组成，每个BB都有一个label,label使得该BB有一个符号表入口点
define i32 @main(){
;创建BB
entry:
;计算条件表达式2>1,结果赋给局部变量cond
  %cond = icmp sgt  i32 2,1
;br用来将控制流转交给当前函数中的另一个BB。
;语法：br i1 <cond>, label <iftrue>, label <iffalse>
  br i1 %cond,label %if_true,label %if_false
if_true:
;ret用来将控制流从callee返回给caller,语法ret <type> <value>
  ret i32 1
if_false:
  ret i32 0
}
