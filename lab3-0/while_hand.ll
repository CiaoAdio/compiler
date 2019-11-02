;ModuleID = 'while.c'，创建while.c模块
;source_filename是表明这个module是从什么文件编译得到的
source_filename="while.c"

;创建main函数,函数返回值类型为i32，对应C语言中的int，@前缀表示main函数为全局函数
;函数体由一系列基本块（BB）组成，每个BB都有一个label,label使得该BB有一个符号表入口点
define i32 @main(){
;创建BB
entry:
;可以通过alloc使用指针的方式间接多次对变量赋值来骗过SSA检查
;alloca指令在当前执行的函数的栈帧上分配内存并返回一个指向这片内存的指针，当函数返回时内存会被自动释放（一般是改变栈指针）。
;语法<result> = alloca [inalloca] <type> [, <ty> <NumElements>] [, align <alignment>] [, addrspace(<num>)]
  %a=alloca i32
  %i=alloca i32
;使用store指令赋值
  store i32 10,i32* %a
  store i32 0,i32* %i
;无条件跳转语法br label <dest>
  br label %check_for_condition

;条件判断
check_for_condition:
  %i1=load i32,i32* %i
  %cond=icmp slt i32 %i1,10
  br i1 %cond,label %while_body,label %end_loop

;条件为真，进入while循环
while_body:
;使用load指令获取i和a的当前值
  %cur_i=load i32,i32* %i
  %i_plus_one=add i32 %cur_i,1
  %cur_a=load i32,i32* %a
  %new_a=add nsw i32 %cur_a,%i_plus_one
;更新i和a的值
  store i32 %i_plus_one,i32* %i
  store i32 %new_a,i32* %a
  br label %check_for_condition

;条件为假，退出循环
end_loop:
;ret用来将控制流从callee返回给caller,语法ret <type> <value>
  %result_a=load i32,i32* %a
  ret i32 %result_a
}
