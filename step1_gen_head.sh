#!/bin/bash
#wsdl2h -help查看选项帮助

if [ ! -d onvif_head ]; then
   mkdir onvif_head
else
   rm -rf onvif_head/*
fi

#下面是所有的wsdl和xsd(下面只有2个xsd)，根据需求添加。在线下载时，xsd可以不管，xsd一般是下载到本地后好像才有用的，具体忘记了。反正在线下载就不会错。

# 其中-c为产生纯c代码，不然为c++代码；-s为不使用STL库，-t为typemap.dat的标识。

DST=onvif_head/onvif.h

wsdl2h -c++11 -x -t gsoap/typemap.dat -o ${DST} \
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
sed -i '122 a #import "wsse.h"' ${DST}

# 有些ONVIF接口调用时需要携带认证信息，要使用soap_wsse_add_UsernameTokenDigest函数进行授权，所以要在onvif.h头文件开头加入
# import "wsse.h"
# 如果onvif.h不加入#import "wsse.h"，使用soap_wsse_add_UsernameTokenDigest函数会导致编译出错（错误信息如下)：
# wsse2api.c(183): error C2039: “wsse__Security”: 不是“SOAP_ENV__Header”的成员
sed -i 's/int SOAP_ENV__Fault$/int SOAP_ENV__Fault_xxx/g' gsoap/import/wsa5.h