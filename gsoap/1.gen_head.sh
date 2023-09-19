#!/bin/bash
#wsdl2h -help查看选项帮助

if [ ! -d ../onvif_head ]; then 
	mkdir ../onvif_head
else
   rm -rf ../onvif_head/*
fi

cd ../onvif_head/

#有些地址缺少onvif节点是因为加上onvif可能会打不开。例如第三个media，但是有时又行，我试过晚上可能比较慢。甚至突然无法下载。我试过有些是因为不支持https协议导致的，可以试试换成http。
#并且注意：想要开发光圈，对比度，饱和度设置的，需要添加imaging.wsdl,这是我后面加上的.不过不是嵌入式的，建议还是全部下载吧，我后面也是全部下载

#下面是所有的wsdl和xsd(下面只有2个xsd)，根据需求添加。在线下载时，xsd可以不管，xsd一般是下载到本地后好像才有用的，具体忘记了。反正在线下载就不会错。

# 其中-c为产生纯c代码，不然为c++代码；-s为不使用STL库，-t为typemap.dat的标识。

wsdl2h -c++11 -x -t ../gsoap/typemap.dat -o onvif.h \
https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl \
https://www.onvif.org/onvif/ver10/network/wsdl/remotediscovery.wsdl \
https://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl \
https://www.onvif.org/onvif/ver10/media/wsdl/media.wsdl \
https://www.onvif.org/onvif/ver20/media/wsdl/media.wsdl 
# https://www.onvif.org/ver10/events/wsdl/event.wsdl \
# http://www.onvif.org/onvif/ver10/display.wsdl \
# http://www.onvif.org/onvif/ver10/deviceio.wsdl \
# http://www.onvif.org/onvif/ver20/imaging/wsdl/imaging.wsdl \
# http://www.onvif.org/onvif/ver10/receiver.wsdl \
# http://www.onvif.org/onvif/ver10/recording.wsdl \
# http://www.onvif.org/onvif/ver10/search.wsdl \
# http://www.onvif.org/onvif/ver10/replay.wsdl \
# http://www.onvif.org/onvif/ver20/analytics/wsdl/analytics.wsdl \
# http://www.onvif.org/onvif/ver10/analyticsdevice.wsdl \
# http://www.onvif.org/onvif/ver10/schema/onvif.xsd \
# http://www.onvif.org/ver10/actionengine.wsdl \
# http://www.onvif.org/ver10/pacs/accesscontrol.wsdl \
# http://www.onvif.org/ver10/pacs/doorcontrol.wsdl \
# http://www.onvif.org/ver10/advancedsecurity/wsdl/advancedsecurity.wsdl \
# http://www.onvif.org/ver10/accessrules/wsdl/accessrules.wsdl \
# http://www.onvif.org/ver10/credential/wsdl/credential.wsdl \
# http://www.onvif.org/ver10/schedule/wsdl/schedule.wsdl \
# http://www.onvif.org/ver10/pacs/types.xsd


#加入鉴权，发送请求需要用户名和密码
sed -i '122 a #import "wsse.h"' onvif.h


# wsdl2h -x -t ./typemap.dat -o onvif.h \
# https://www.onvif.org/ver10/device/wsdl/devicemgmt.wsdl \
# https://www.onvif.org/ver10/events/wsdl/event.wsdl \
# http://www.onvif.org/onvif/ver10/network/wsdl/remotediscovery.wsdl \
# http://www.onvif.org/onvif/ver10/display.wsdl \
# http://www.onvif.org/onvif/ver10/deviceio.wsdl \
# http://www.onvif.org/onvif/ver20/imaging/wsdl/imaging.wsdl \
# http://www.onvif.org/onvif/ver10/media/wsdl/media.wsdl \
# http://www.onvif.org/onvif/ver20/media/wsdl/media.wsdl \
# http://www.onvif.org/onvif/ver20/ptz/wsdl/ptz.wsdl \
# http://www.onvif.org/onvif/ver10/receiver.wsdl \
# http://www.onvif.org/onvif/ver10/recording.wsdl \
# http://www.onvif.org/onvif/ver10/search.wsdl \
# http://www.onvif.org/onvif/ver10/replay.wsdl \
# http://www.onvif.org/onvif/ver20/analytics/wsdl/analytics.wsdl \
# http://www.onvif.org/onvif/ver10/analyticsdevice.wsdl \
# http://www.onvif.org/onvif/ver10/schema/onvif.xsd \
# http://www.onvif.org/ver10/actionengine.wsdl \
# http://www.onvif.org/ver10/pacs/accesscontrol.wsdl \
# http://www.onvif.org/ver10/pacs/doorcontrol.wsdl \
# http://www.onvif.org/ver10/advancedsecurity/wsdl/advancedsecurity.wsdl \
# http://www.onvif.org/ver10/accessrules/wsdl/accessrules.wsdl \
# http://www.onvif.org/ver10/credential/wsdl/credential.wsdl \
# http://www.onvif.org/ver10/schedule/wsdl/schedule.wsdl \
# http://www.onvif.org/ver10/pacs/types.xsd
# http://www.onvif.org/onvif/ver10/device/wsdl/devicemgmt.wsdl \
# http://www.onvif.org/onvif/ver10/events/wsdl/event.wsdl \

# 有些ONVIF接口调用时需要携带认证信息，要使用soap_wsse_add_UsernameTokenDigest函数进行授权，所以要在onvif.h头文件开头加入
# import "wsse.h"
# 如果onvif.h不加入#import "wsse.h"，使用soap_wsse_add_UsernameTokenDigest函数会导致编译出错（错误信息如下)：
# wsse2api.c(183): error C2039: “wsse__Security”: 不是“SOAP_ENV__Header”的成员
