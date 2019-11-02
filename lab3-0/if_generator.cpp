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

using namespace llvm;  // 指明命名空间为llvm
#define CONST(num) \
  ConstantInt::get(context, APInt(32, num))  // 得到常数值的表示,方便后面多次用到

int main() {
  LLVMContext context;
  Type *TYPE32 = Type::getInt32Ty(context);
  IRBuilder<> builder(context);
  auto module = new Module("if", context);  // module name是什么无关紧要

  std::vector<Type *> Ints(2, TYPE32);  // 函数参数类型的vector

   // main函数
  auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main",module);
  auto bb = BasicBlock::Create(context, "entry", mainFun);
  builder.SetInsertPoint(bb);  // 一个BB的开始  
  auto trueBB = BasicBlock::Create(context, "trueBB", mainFun);    // true分支
  auto falseBB = BasicBlock::Create(context, "falseBB", mainFun);  // false分支
  
  auto icmp = builder.CreateICmpSGT(CONST(2), CONST(1));  //条件判断，计算条件表达式2>1
  auto br = builder.CreateCondBr(icmp, trueBB, falseBB);  // 条件BR

  builder.SetInsertPoint(trueBB);  // trueBB开始; 分支的开始需要SetInsertPoint设置
  builder.CreateRet(CONST(1));  // return 1

  builder.SetInsertPoint(falseBB);  // falseBB开始
  builder.CreateRet(CONST(0));  // return 0

  module->print(outs(), nullptr);
  delete module;
  return 0;
}