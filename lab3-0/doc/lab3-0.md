## lab3-0实验报告

姓名：张陶竞

学号：PB17111637

### 代码片段和每一个BasicBlock的对应关系

(1)assign<br />

bb<br />
> entry:<br />
  %0=alloca i32<br />
  store i32 1, i32* %0<br />
  %1=load i32,i32* %0<br />
  ret i32 %1  <br /><br />
对应关系<br />
>  //`entry:`<br />
> builder.SetInsertPoint(bb);  <br />
  //`%0=alloca i32`<br />
  auto aAlloca = builder.CreateAlloca(TYPE32);  // 局部变量a的空间分配<br />
  //`store i32 1, i32* %0`<br />
  builder.CreateStore(CONST(1), aAlloca);  // store a值<br />
  //`%1=load i32,i32* %0`<br />
  auto aload = builder.CreateLoad(aAlloca);  // load a值<br />
  //`ret i32 %1`  <br />
  builder.CreateRet(aload);  // return a值<br />

<br />

(2)if<br />

bb<br />
>entry:<br />
  br i1 true,label %trueBB,label %falseBB<br /><br />
对应关系<br />
>//`entry:`<br />
> builder.SetInsertPoint(bb);  // 一个BB的开始  
//`br i1 true,label %trueBB,label %falseBB`<br />
  auto icmp = builder.CreateICmpSGT(CONST(2), CONST(1));  //条件判断，计算条件表达式2>1<br />
  auto br = builder.CreateCondBr(icmp, trueBB, falseBB);  // 条件BR<br />

trueBB

>trueBB:<br />
  ret i32 1<br /><br />
对应关系<br />
//`trueBB:`<br />
>builder.SetInsertPoint(trueBB);  // trueBB开始; 分支的开始需要SetInsertPoint设置<br />
>//`ret i32 1`<br />
  builder.CreateRet(CONST(1));  // return 1<br />

falseBB

>falseBB:<br />
  ret i32 0<br /><br />
对应关系<br />
>`falseBB:`<br />
>builder.SetInsertPoint(falseBB);  // falseBB开始<br />
>`ret i32 0`<br />
  builder.CreateRet(CONST(0));  // return 0<br />

(3)while<br />
bb<br />
>entry:<br />
  %0=alloca i32<br />
  %1=alloca i32<br />
  store i32 10,i32* %0<br />
  store i32 0,i32* %1<br />
  br label %condBB<br /><br />
对应关系<br />
//`entry:`<br />
>builder.SetInsertPoint(bb);  // 一个BB的开始<br />
>//`%0=alloca i32`<br />
  auto aAlloca = builder.CreateAlloca(TYPE32);   // 参数a的空间分配<br />
//`%1=alloca i32`<br />
  auto iAlloca = builder.CreateAlloca(TYPE32);   // 参数i的空间分配<br />
//`store i32 10,i32* %0`<br />
  builder.CreateStore(CONST(10), aAlloca);  // store a<br />
//`store i32 0,i32* %1`<br />
  builder.CreateStore(CONST(0), iAlloca);  // store i<br />
//`br label %condBB`<br />
  auto br = builder.CreateBr(condBB);  // 无条件BR<br />

while_bodyBB<br />
>while_bodyBB:<br />
  %2=add i32 %7,1<br />
  store i32 %2,i32* %1<br />
  %3=load i32,i32* %1<br />
  %4=load i32,i32* %0<br />
  %5=add i32 %4,%3<br />
  store i32 %5,i32* %0<br />
  br label %condBB<br /><br />
对应关系<br />
//`while_bodyBB:`<br />
>builder.SetInsertPoint(while_bodyBB);  // while_bodyBB的开始<br />
>//`%2=add i32 %7,1`<br />
  auto new_i = builder.CreateAdd(iload,CONST(1));  // i=i+1<br />
//`store i32 %2,i32* %1`<br />
  builder.CreateStore(new_i, iAlloca);  // store i<br />
//`%3=load i32,i32* %1`<br />
  iload = builder.CreateLoad(iAlloca);  // load i<br />
//`%4=load i32,i32* %0`<br />
  auto aload = builder.CreateLoad(aAlloca);  // load a<br />
//`%5=add i32 %4,%3`<br />
  auto new_a = builder.CreateAdd(aload, iload);  // a=a+i <br />
//`store i32 %5,i32* %0`<br />
  builder.CreateStore(new_a, aAlloca);  // store a<br />
//`br label %condBB`<br />
  br = builder.CreateBr(condBB);  //无条件BR<br />

endloopBB<br />

>endloopBB:<br />
  %6=load i32,i32* %0<br />
  ret i32 %6<br /><br />
对应关系<br />
//`endloopBB:`<br />
>builder.SetInsertPoint(endloopBB);  // endloopBB的开始<br />
>//`%6=load i32,i32* %0`<br />
  auto res = builder.CreateLoad(aAlloca);  // load res  <br />
//`ret i32 %6`<br />
  builder.CreateRet(res);  // return res<br /><br />

condBB<br />
>condBB:<br />
  %7=load i32,i32* %1<br />
  %8=icmp slt i32 %7,10<br />
  br i1 %8,label %while_bodyBB,label %endloopBB<br /><br />
对应关系<br />
//`condBB:`<br />
>builder.SetInsertPoint(condBB);  // condBB的开始<br />
>//`%7=load i32,i32* %1`<br />
  auto iload = builder.CreateLoad(iAlloca);  // load a<br />
//`%8=icmp slt i32 %7,10`<br />
  auto icmp = builder.CreateICmpSLT(iload, CONST(10));  // 条件判断<br />
//`br i1 %8,label %while_bodyBB,label %endloopBB`<br />
  br = builder.CreateCondBr(icmp, while_bodyBB, endloopBB);  // 条件BR<br />



(4)call<br />
main_bb<br />
>entry:<br />
  %0=call i32 @callee(i32 10)<br />
  ret i32 %0<br /><br />
对应关系<br />
//`entry:`<br />
  builder.SetInsertPoint(bb);  // 一个BB的开始<br />
//`%0=call i32 @callee(i32 10)`<br />
  auto call = builder.CreateCall(calleeFun, CONST(10));  // 调用callee函数，参数值为10<br />
//`ret i32 %0<br />`<br />
  builder.CreateRet(call);  // 返回callee函数的返回值<br />

callee_bb<br />
>entry:<br />
  %1=alloca i32<br />
  store i32 %0,i32* %1<br />
  %2=load i32,i32* %1<br />
  %3=mul nsw i32 2,%2<br />
  ret i32 %3<br /><br />
对应关系<br />
>//`entry:`<br />
  builder.SetInsertPoint(bb);  //一个BB的开始<br />
//`%1=alloca i32`<br />
  auto aAlloca = builder.CreateAlloca(TYPE32);    // 参数a的空间分配<br />
  std::vector<Value *> args;  //获取callee函数的参数,通过iterator<br />
  for (auto arg = calleeFun->arg_begin(); arg != calleeFun->arg_end(); arg++) {<br />
    args.push_back(arg);<br />
  }<br />
//`store i32 %0,i32* %1`<br />
  builder.CreateStore(args[0], aAlloca);  // store a<br />
//`%2=load i32,i32* %1`<br />
  auto aload = builder.CreateLoad(aAlloca);  // load a<br />
//`%3=mul nsw i32 2,%2`<br />
  auto mul = builder.CreateNSWMul(CONST(2), aload);   // 计算2 * a<br />
//`ret i32 %3`<br /> 
  builder.CreateRet(mul);  // 返回计算结果<br />
### 实验难点
手工翻译while.c时LLVM IR静态单赋值的问题<br />
参考官方LLVM IR参考手册和机器生成的.ll文件，解决方法如下：<br />
方法1:使用phi指令<br />
语法<br />`<result> = phi <ty> [<val0>, <label0>], [<val1>, <label1>] …`<br />
概述<br />
根据前一个执行的是哪一个BB来选择一个变量的值。<br />
方法2:使用alloca指令<br />
语法：`<result> = alloca [inalloca] <type> [, <ty> <NumElements>] [, align <alignment>] [, addrspace(<num>)]`<br />
概述：在当前执行的函数的栈帧上分配内存并返回一个指向这片内存的指针，当函数返回时内存会被自动释放（一般是改变栈指针）。<br />

