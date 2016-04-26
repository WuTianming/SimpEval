#!/bin/bash
# SimpEval v1.0.0
# Simple script, Compile & Run & Evaluate

end='out'                                           # File suffix, defaults to 'out'

#----------HELP-INFO----------#
if [ "$1" = "--version" ]; then
    echo "Cena.sh v1.00"
    echo "Written by wtm"
    exit 0
fi

if [ "$1" = "-v" ]; then
    echo "Cena.sh v1.00"
    echo "Written by wtm"
    exit 0
fi

#----------ERRORS----------#
if [ "$1" = "" ]; then
    echo "必须输入程序名称！！！"
    exit 1
fi

if [ ! -d "src/code/${1}" ]; then
    echo "题目文件夹不存在！！！"
fi

#----------STARTS----------#
echo "开始评测：${1}"
score=0

#----------COMPILES----------#
if [ -f "src/code/${1}/${1}.c" ]; then              # Found C code
    gcc "src/code/${1}/${1}.c" "-o" "src/code/${1}.autobuilt" "-lm" >/dev/null 2>&1
    if [ ! $? = 0  ]; then
        echo "编译失败！"
        echo "评测结束: ${1}"
        echo "分数: 0分"
        exit 0
    fi
elif [ -f "src/code/${1}/${1}.cpp" ]; then          # Found C++ code
    g++ "src/code/${1}/${1}.cpp" "-o" "src/code/${1}.autobuilt" "-lm" >/dev/null 2>&1
    if [ ! $? = 0  ]; then
        echo "编译失败！"
        echo "评测结束: ${1}"
        echo "分数: 0分"
        exit 0
    fi
elif [ -f "src/code/${1}/${1}.pas" ]; then          # Found Pascal code
    fpc "-Tlinux" "src/code/${1}/${1}.pas" >/dev/null 2>&1
    if [ ! $? = 0  ]; then
        echo "编译失败！"
        echo "评测结束: ${1}"
        echo "分数: 0分"
        exit 0
    fi
    mv "src/code/${1}/${1}" "src/code/${1}.autobuilt"
fi

#----------RUN&EVALUATE----------#
for i in $2; do
    cp data/${1}/${1}${i}.in ${1}.in                # Get input file ready
    timeout 1 src/code/${1}.autobuilt               # Run the program
    diff -Z -B data/${1}/${1}${i}.${end} ${1}.out > .__SETemp.diff 2>/dev/null  # Check the result
    if [ ! -f "${1}.out"  ]; then                   # No output file
        echo "第 #${i} 个测试点错误(无输出)"
    elif [ "`cat ${1}.out`" = "" ]; then            # Output file empty
        echo "第 #${i} 个测试点错误(无输出)"
    elif [ "`cat .__SETemp.diff`" = "" ]; then      # No error
        echo "第 #${i} 个测试点正确"
        score=`expr ${score} + 10`
    else                                            # Wrong answer
        echo "第 #${i} 个测试点错误"
        diff -Z -B data/${1}/${1}${i}.${end} ${1}.out
    fi
    rm -rf .__SETemp.diff
    rm -rf ${1}.in
    rm -rf ${1}.out
done

#----------DONE----------#
rm -rf src/code/${1}.autobuilt
echo "评测结束：${1}"
echo "分数：${score}分"
exit ${score}
