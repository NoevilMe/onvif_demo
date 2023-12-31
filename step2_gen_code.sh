#!/bin/bash

if [ ! -d soap ]; then
   mkdir soap
else
   rm -rf soap/*
fi

# wsa5.h(288): **ERROR**: service operation name clash: struct/class 'SOAP_ENV__Fault' already declared at wsa.h:273
# 修改import\wsa5.h文件，将int SOAP_ENV__Fault修改为int SOAP_ENV__Fault_alex，再次使用soapcpp2工具编译就成功了

# ../bin/soapcpp2 -2 -x -C ../onvif_head/onvif.h  -L -I ../gsoap/import -I ../gsoap/
#-2表示获取1.2资源代码,-x表示不获取XML信息文件,-C表示只生成客户端代码
#-L表示不生成客户端或者服务端的库，-I表示import导入路径

pushd gsoap
soapcpp2 -2 -c++11 -C -L -x -I import:custom -d ../onvif ../onvif_head/onvif.h
popd

# 拷贝其他还有会用的源码
cp gsoap/stdsoap2.cpp gsoap/stdsoap2.h gsoap/plugin/wsaapi.c gsoap/plugin/wsaapi.h gsoap/custom/duration.c gsoap/custom/duration.h soap
cp gsoap/custom/struct_timeval.* soap
mv soap/struct_timeval.c soap/struct_timeval.cpp
mv soap/wsaapi.c soap/wsaapi.cpp
mv soap/duration.c soap/duration.cpp

# 用于授权验证的一些文件
cp gsoap/dom.cpp gsoap/plugin/mecevp.* gsoap/plugin/smdevp.* gsoap/plugin/threads.* gsoap/plugin/wsseapi.* soap
mv soap/mecevp.c soap/mecevp.cpp
mv soap/smdevp.c soap/smdevp.cpp
mv soap/threads.c soap/threads.cpp

# 删除多余nsmap——都一样，冗余了
mv onvif/wsdd.nsmap onvif/wsdd.nsmap.bak
rm onvif/*.nsmap
mv onvif/wsdd.nsmap.bak onvif/wsdd.nsmap
