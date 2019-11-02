#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>

#include <iostream>
#include <memory>

#ifdef DEBUG  // 用于调试信息,大家可以在编译过程中通过" -DDEBUG"来开启这一选项
#define DEBUG_OUTPUT std::cout << __LINE__ << std::endl;  // 输出行号的简单示例
#else
#define DEBUG_OUTPUT
#endif

using namespace llvm;
#define CONST(num) \
  ConstantInt::get(context, APInt(32, num))  //得到常数值的表示,方便后面多次用到

int main() {
  LLVMContext context;
  Type *TYPE32 = Type::getInt32Ty(context);
  IRBuilder<> builder(context);
  auto module = new Module("while", context);  // module name是什么无关紧要

  // 函数参数类型的vector
  std::vector<Type *> Ints(2, TYPE32);
   // main函数
  auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main",module);

  auto bb = BasicBlock::Create(context, "entry", mainFun);
  // BasicBlock的名字在生成中无所谓,但是可以方便阅读
  builder.SetInsertPoint(bb);

  auto while_bodyBB = BasicBlock::Create(context, "while_bodyBB", mainFun);    // true分支
  auto endloopBB = BasicBlock::Create(context, "endloopBB", mainFun);  // false分支
  auto condBB = BasicBlock::Create(context, "condBB", mainFun);  // false分支
  
  auto aAlloca = builder.CreateAlloca(TYPE32);    // 参数v的空间分配
  auto iAlloca = builder.CreateAlloca(TYPE32);    // 参数v的空间分配

  builder.CreateStore(CONST(10), aAlloca);  
  builder.CreateStore(CONST(0), iAlloca);  
  auto br = builder.CreateBr(condBB);

  builder.SetInsertPoint(condBB);
  auto iload = builder.CreateLoad(iAlloca); 
  auto icmp = builder.CreateICmpSLT(iload, CONST(10));
  br = builder.CreateCondBr(icmp, while_bodyBB, endloopBB);  // 条件BR

  builder.SetInsertPoint(while_bodyBB);  // if true; 分支的开始需要SetInsertPoint设置
  auto new_i = builder.CreateAdd(iload,CONST(1));  // SDIV - div with S flag
  builder.CreateStore(new_i, iAlloca); 
  iload = builder.CreateLoad(iAlloca);
  auto aload = builder.CreateLoad(aAlloca); 
  auto new_a = builder.CreateAdd(aload, iload);  
  builder.CreateStore(new_a, aAlloca); 
  br = builder.CreateBr(condBB);

  builder.SetInsertPoint(endloopBB);  // if true; 分支的开始需要SetInsertPoint设置
  auto res = builder.CreateLoad(aAlloca); 
  builder.CreateRet(res);

  module->print(outs(), nullptr);
  delete module;
  return 0;
}