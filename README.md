# 目录说明
- gsoap 源码目录（直接从gosap下复制过来的，用来生成后面的一些文件）
- soap 以后工程上会用到的一些文件可以放这里。直接从gsoap目录下复制，但是有些文件被重命名为cpp
- onvif 根据wsdl生成的一些文件
- tests 示例
- onvif_head 中间文件，可以删除

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

# 复制会用到的源码
# 以下文件（夹）复制到gsoap目录下（脚本已经自动完成了）
- gsoap/import
- gsoap/custom
- gsoap/plugin
- gsoap/stdsoap2.cpp
- gsoap/stdsoap2.h
- gsoap/typemap.dat
- ...

## 修改typemap.dat

由于后续编译源代码需要用到 duration.c 文件，会遇到类型LONG64报错的问题，需要typemap.dat 文件中取消以下行的注释：

xsd__duration = #import “custom/duration.h” | xsd__duration


# 生成头文件onvif.h
## 执行命令
> ./step1_gen_head.sh

此步骤会生成onvif_head/onvif.h文件。
该脚本会在线下载wsdl文件（需要自己配置），并且修改onvif.h文件，加入鉴权的相关项。
## 命令解析
step1_gen_head.sh主要使用了wsdl2h命令来生成onvif.h文件。wsdl2h参数解析：
```
-c ： 生成c风格代码（注：后缀名还是.cpp ，但实际上是.c）
-c++：生成c++风格代码（注 : 默认是生成c++代码）
-x : 表示不生成xml 文件（注：生成的xml文件，有助于了解发送是SOAP是怎样的结构，建议不使用-x）
-l : 表示指定导入路径
-C : 表示生成客户端代码
-S : 表示生成服务端代码
-s : 不使用STL代码
-o: 生成.h文件叫什么名字
-t : 后面紧跟“typemap.dat”这个批处理文件
```
## 关于鉴权
如果onvif.h不加入#import "wsse.h"，使用soap_wsse_add_UsernameTokenDigest函数会导致编译出错，也就无法登录设备进行操作了。

## wsdl相关文件的功能范围
- https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl 用于获取设备参数
- https://www.onvif.org/onvif/ver10/network/wsdl/remotediscovery.wsdl 用于发现设备
- https://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl 云台控制
- https://www.onvif.org/onvif/ver10/media/wsdl/media.wsdl 获取264的视频流地址
- https://www.onvif.org/onvif/ver20/media/wsdl/media.wsdl 获取h265视频流地址
- http://www.onvif.org/onvif/ver20/imaging/wsdl/imaging.wsdl 光圈，对比度，饱和度

## 执行结果

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

# 生成代码
生成可以用于工程实践的相关源代码文件

## gsoap源代码类型重复定义
如果没有修改相关文件，生成代码的时候会出现如下错误。
```
wsa5.h(280): *WARNING*: Duplicate declaration of 'SOAP_ENV__Fault' (already declared at line 268)
wsa5.h(290): **ERROR**: service operation name clash: struct/class 'SOAP_ENV__Fault' already declared at wsa.h:278

```
之所有会出现这个错误，是因为onvif.h头文件中同时：

> #import "wsdd10.h" // wsdd10.h中又#import "wsa.h" 

> #import "wsa5.h"   // wsa.h和wsa5.h两个文件重复定义了int SOAP_ENV__Fault

### 解决方法：
修改import\wsa5.h文件，将int SOAP_ENV__Fault修改为int SOAP_ENV__Fault_xxx，再次使用soapcpp2工具编译就成功了


## 执行生成命令
>./step2_gen_code.sh


脚本已经删除了一些无用文件、复制并重命名了相关文件。

### 删除无用文件

其中onvif.h文件其实已经没用了，可以删掉，不需要参与后续IPC客户端程序的编译。这里有好多个命名空间的.nsmap文件，文件内容都一模一样，拿wsdd.nsmap一个来用即可，其他也没卵用。

### 复制其他可能有用的一些文件
soapC.c会调用到soap_in_xsd__duration函数，需要duration.c和duration.h文件。
后续示例代码会调用到soap_wsa_rand_uuid函数（用于生成UUID），需要wsaapi.c和wsaapi.h文件。

### 保留文件说明
• 各种nsmap文件：命名空间，除了名字不一样，内容是一样的，里面的内容竟然是每一个xml文件里的Envelope字段内容。我们只需要留下一个就可以了，并将之改名为wsdd.nsmap
• soapC.cpp：指定数据结构的序列化和反序列化
• soapClient.cpp：客户端代码
• soapH.h：主头文件，所有客户机和服务器源代码都要包括它
• soapStub.h：从输入头文件（onvif.h）生成的经过修改且带命名空间前缀的头文件