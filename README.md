# 下载编译gSoap
安装依赖 
> sudo apt install bison flex openssl

下载
- http://www.cs.fsu.edu/~engelen/soap.html
- https://sourceforge.net/projects/gsoap2/files/

要用gsoap生成onvif源码，必须用到wsdl2h和soapcpp2两个工具（执行文件）。
wsdl2h默认不支持HTTPS，编译的时候需要开启https支持

编译
> ./configure

> make -j4

> sudo make install

# 在gsoap目录操作
## 复制源码gsoap/typemap.dat到目录下
## 生成onvif.h
执行命令
> ./1.gen_head.sh

该脚本会下载相应wsdl文件（需要自己配置），并且修改onvif.h文件，加入鉴权的相关项。如果onvif.h不加入#import "wsse.h"，使用soap_wsse_add_UsernameTokenDigest函数会导致编译出错

执行结果如下：
```
gsoap$ ./1.gen_head.sh 
Saving onvif.h


**  The gSOAP WSDL/WADL/XSD processor for C and C++, wsdl2h release 2.8.130
**  Copyright (C) 2000-2023 Robert van Engelen, Genivia Inc.
**  All Rights Reserved. This product is provided "as is", without any warranty.
**  The wsdl2h tool and its generated software are released under the GPL.
**  ----------------------------------------------------------------------------
**  A commercial use license is available from Genivia Inc., contact@genivia.com
**  ----------------------------------------------------------------------------

Reading type definitions from type map "../gsoap/typemap.dat"
Connecting to 'https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl' to retrieve WSDL/WADL or XSD... connected, receiving...
  Connecting to 'https://www.onvif.org/ver10/schema/onvif.xsd' to retrieve schema... connected, receiving...
    Connecting to 'http://docs.oasis-open.org/wsn/b-2.xsd' to retrieve schema... connected, receiving...
      Connecting to 'http://docs.oasis-open.org/wsrf/bf-2.xsd' to retrieve schema... connected, receiving...
      Done reading 'http://docs.oasis-open.org/wsrf/bf-2.xsd'
      Connecting to 'http://docs.oasis-open.org/wsn/t-1.xsd' to retrieve schema... connected, receiving...
      Done reading 'http://docs.oasis-open.org/wsn/t-1.xsd'
    Done reading 'http://docs.oasis-open.org/wsn/b-2.xsd'
    Connecting to 'https://www.onvif.org/ver10/schema/common.xsd' to retrieve schema... connected, receiving...
    Done reading 'https://www.onvif.org/ver10/schema/common.xsd'
  Done reading 'https://www.onvif.org/ver10/schema/onvif.xsd'
Done reading 'https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl'
Connecting to 'https://www.onvif.org/onvif/ver10/network/wsdl/remotediscovery.wsdl' to retrieve WSDL/WADL or XSD... connected, receiving...
Done reading 'https://www.onvif.org/onvif/ver10/network/wsdl/remotediscovery.wsdl'
Connecting to 'https://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl' to retrieve WSDL/WADL or XSD... connected, receiving...
Done reading 'https://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl'
Connecting to 'https://www.onvif.org/onvif/ver10/media/wsdl/media.wsdl' to retrieve WSDL/WADL or XSD... connected, receiving...
Done reading 'https://www.onvif.org/onvif/ver10/media/wsdl/media.wsdl'
Connecting to 'https://www.onvif.org/onvif/ver20/media/wsdl/media.wsdl' to retrieve WSDL/WADL or XSD... connected, receiving...
Done reading 'https://www.onvif.org/onvif/ver20/media/wsdl/media.wsdl'

Note: option -p auto-enabled to generate wrappers for built-in types derived from xsd__anyType to support polymorphism in XML by (de)serializing any derived type of xsd:anyType (or xsd:anySimpleType) as elements annotated by xsi:type attributes in XML, use option -P to suppress and disable this feature

Warning: 2 service bindings found, but collected as one service (use option -Nname to produce a separate service for each binding)

To finalize code generation, execute:
> soapcpp2 onvif.h
Or to generate C++ proxy and service classes:
> soapcpp2 -j onvif.h

```

## 生成代码

### 复制下列源代码到gsoap下
- gsoap/import
- gsoap/custom
- gsoap/plugin
- stdsoap2.cpp
- stdsoap2.h

### 修改文件避免错误
```
wsa5.h(280): *WARNING*: Duplicate declaration of 'SOAP_ENV__Fault' (already declared at line 268)
wsa5.h(290): **ERROR**: service operation name clash: struct/class 'SOAP_ENV__Fault' already declared at wsa.h:278

```
之所有会出现这个错误，是因为onvif.h头文件中同时：

> #import "wsdd10.h" // wsdd10.h中又#import "wsa.h" 

> #import "wsa5.h"   // wsa.h和wsa5.h两个文件重复定义了int SOAP_ENV__Fault

解决方法：

修改import\wsa5.h文件，将int SOAP_ENV__Fault修改为int SOAP_ENV__Fault_alex，再次使用soapcpp2工具编译就成功了


### 执行生成命令
>./2.gen_code.sh


关联自己的命名空间，修改stdsoap2.c文件

在samples\onvif\stdsoap2.h中有命名空间「namespaces变量」的定义声明，如下所示：

extern SOAP_NMAC struct Namespace namespaces[];
1
但「namespaces变量」的定义实现，是在samples\onvif\wsdd.nsmap文件中，为了后续应用程序要顺利编译，修改samples\onvif\stdsoap2.c文件，在开头加入：

#include "wsdd.nsmap"
1
当然，你可以在其他源码中（更上层的应用程序源码）include，我这里是选择在stdsoap2.c中include
————————————————
版权声明：本文为CSDN博主「许振坪」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/benkaoya/article/details/72466827

其中onvif.h文件其实已经没用了，可以删掉，不需要参与后续IPC客户端程序的编译。这里有好多个命名空间的.nsmap文件，文件内容都一模一样，拿wsdd.nsmap一个来用即可，其他也没卵用。