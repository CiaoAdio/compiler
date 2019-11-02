;Modu;ModuleID = 'call.c'，创建call.c模块
;source_filename是表明这个module是从什么文件编译得到的
source_filename="call.c"

;创建main函数,函数返回值类型为i32，对应C语言中的int，@前缀表示main函数为全局函数
;函数体由一系列基本块（BB）组成，每个BB都有一个label,label使得该BB有一个符号表入口点
define i32 @main(){
;创建BB
entry:
;使用call指令调用callee函数
;call语法：<result> = [tail | musttail | notail ] call [fast-math flags] [cconv] [ret attrs] [addrspace(<num>)]<ty>|<fnty> <fnptrval>(<function args>) [fn attrs] [ operand bundles ]
  %call=call i32 @callee(i32 10)
  ret i32 %call
}

;创建全局函数callee，形参a类型为i32，返回值类型为i32
define i32 @callee(i32 %a){
entry:
  %res=mul nsw i32 %a,2
;ret用来将控制流从callee返回给caller,语法ret <type> <value>
  ret i32 %res
}
