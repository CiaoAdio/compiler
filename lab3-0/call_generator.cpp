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
  auto module = new Module("call", context);  // module name是什么无关紧要

  std::vector<Type *> Ints(1, TYPE32);  // 函数参数类型的vector

   // callee函数
  auto calleeFun = Function::Create(FunctionType::get(TYPE32,Ints,false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "callee",module);
  auto bb = BasicBlock::Create(context, "entry", calleeFun);
  builder.SetInsertPoint(bb);  //一个BB的开始
  auto aAlloca = builder.CreateAlloca(TYPE32);    // 参数a的空间分配

  std::vector<Value *> args;  //获取callee函数的参数,通过iterator
  for (auto arg = calleeFun->arg_begin(); arg != calleeFun->arg_end(); arg++) {
    args.push_back(arg);
  }

  builder.CreateStore(args[0], aAlloca);  // store a
  auto aload = builder.CreateLoad(aAlloca);  // load a
  auto mul = builder.CreateNSWMul(CONST(2), aload);   // 计算2*a 
  builder.CreateRet(mul);  // 返回计算结果
   
   // main函数
  auto mainFun = Function::Create(FunctionType::get(TYPE32, false),
                                  GlobalValue::LinkageTypes::ExternalLinkage,
                                  "main",module);
  bb = BasicBlock::Create(context, "entry", mainFun);
  builder.SetInsertPoint(bb);  // 一个BB的开始
  auto call = builder.CreateCall(calleeFun, CONST(10));  // 调用callee函数，参数值为10
  builder.CreateRet(call);  // 返回callee函数的返回值

  module->print(outs(), nullptr);
  delete module;
  return 0;
}