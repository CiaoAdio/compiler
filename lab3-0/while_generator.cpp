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

  std::vector<Type *> Ints(2, TYPE32);  // 函数参数类型的vector

   // main函数
  auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main",module);
  auto bb = BasicBlock::Create(context, "entry", mainFun);
  builder.SetInsertPoint(bb);  // 一个BB的开始
  auto while_bodyBB = BasicBlock::Create(context, "while_bodyBB", mainFun);    // while_bodyBB分支
  auto endloopBB = BasicBlock::Create(context, "endloopBB", mainFun);  // endloopBB分支
  auto condBB = BasicBlock::Create(context, "condBB", mainFun);  // condBB分支
  
  auto aAlloca = builder.CreateAlloca(TYPE32);   // 参数a的空间分配
  auto iAlloca = builder.CreateAlloca(TYPE32);   // 参数i的空间分配

  builder.CreateStore(CONST(10), aAlloca);  // store a
  builder.CreateStore(CONST(0), iAlloca);  // store i
  auto br = builder.CreateBr(condBB);  // 无条件BR

  builder.SetInsertPoint(condBB);  // condBB的开始
  auto iload = builder.CreateLoad(iAlloca);  // load a
  auto icmp = builder.CreateICmpSLT(iload, CONST(10));  // 条件判断
  br = builder.CreateCondBr(icmp, while_bodyBB, endloopBB);  // 条件BR

  builder.SetInsertPoint(while_bodyBB);  // while_bodyBB的开始
  auto new_i = builder.CreateAdd(iload,CONST(1));  // i=i+1
  builder.CreateStore(new_i, iAlloca);  // store i
  iload = builder.CreateLoad(iAlloca);  // load i
  auto aload = builder.CreateLoad(aAlloca);  // load a
  auto new_a = builder.CreateAdd(aload, iload);  // a=a+i 
  builder.CreateStore(new_a, aAlloca);  // store a
  br = builder.CreateBr(condBB);  //无条件BR

  builder.SetInsertPoint(endloopBB);  // endloopBB的开始
  auto res = builder.CreateLoad(aAlloca);  // load res  
  builder.CreateRet(res);  // return res

  module->print(outs(), nullptr);
  delete module;
  return 0;
}