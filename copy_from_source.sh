# 将要用到的一些源码文件复制到gsoap目录

# 自己修改源码目录
SRC_DIR=~/opensource/gsoap-2.8

if [ ! -d $SRC_DIR ]; then
    echo ${SRC_DIR} does not exist!
    exit 1
fi

FROM_DIR=$SRC_DIR/gsoap
if [ ! -d $FROM_DIR ]; then
    echo ${FROM_DIR} does not exist!
    exit 1
fi

if [ ! -d gsoap ]; then
    mkdir gsoap
fi

TARGET_DIR=gsoap

# 要复制的目录和文件
LISTS="custom import plugin dom.cpp stdsoap2.h stdsoap2.cpp"
for t in ${LISTS}; do
    ft=${FROM_DIR}/${t}
    if [ -d ${ft} ]; then
        echo ${ft} is an directory
        cp -rf ${ft} ${TARGET_DIR}
    elif [ -f ${ft} ]; then
        echo ${ft} is a file
        cp -rf ${ft} ${TARGET_DIR}
    else
        echo ${ft} does not exist!
    fi
done

# typemap.dat 不要覆盖，这个会被修改了
if [ ! -f gsoap/typemap.dat ]; then
    cp ${FROM_DIR}/typemap.dat gsoap/typemap.dat
else
    echo "typemap.dat exists! do not copy it!"
fi
