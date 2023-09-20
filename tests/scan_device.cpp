#include "onvif/soapH.h"
#include "soap/wsaapi.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "onvif/wsdd.nsmap"

#define SOAP_ASSERT assert
#define SOAP_DBGLOG printf
#define SOAP_DBGERR printf

#define SOAP_SOCK_TIMEOUT (10) // socket超时时间（单秒秒）

#define SOAP_CHECK_ERROR(result, soap, str)                                    \
    do {                                                                       \
        if (SOAP_OK != (result) || SOAP_OK != (soap)->error) {                 \
            soap_perror((soap), (str));                                        \
            if (SOAP_OK == (result)) {                                         \
                (result) = (soap)->error;                                      \
            }                                                                  \
            goto EXIT;                                                         \
        }                                                                      \
    } while (0)

void soap_perror(struct soap *soap, const char *str) {

    //   if (soap->error)
    // soap_print_fault(soap, stderr);
    if (NULL == str) {
        SOAP_DBGERR("[soap] error: %d, %s, %s\n", soap->error,
                    *soap_faultcode(soap), *soap_faultstring(soap));
    } else {
        SOAP_DBGERR("[soap] %s error: %d, %s, %s\n", str, soap->error,
                    *soap_faultcode(soap), *soap_faultstring(soap));
    }
    return;
}

#define SOAP_TO "urn:schemas-xmlsoap-org:ws:2005:04:discovery"
#define SOAP_ACTION "http://schemas.xmlsoap.org/ws/2005/04/discovery/Probe"
#define SOAP_MCAST_ADDR "soap.udp://239.255.255.250:3702" // onvif规定的组播地址
#define SOAP_ITEM ""                                   // 寻找的设备范围
#define SOAP_COMPAT_TYPES "dn:NetworkVideoTransmitter" // 寻找的设备类型

class OnvifSoap {
public:
    OnvifSoap(int timeout) {
        // There is no need to call soap_init to initialize the context
        // allocated with soap_new, since soap_new initializes the allocated
        // context.
        soap_ = soap_new();

        soap_set_namespaces(soap_, namespaces); // 设置soap的namespaces

        // 不正常数据设置成20s
        if (timeout <= 0)
            timeout = 20;

        soap_->recv_timeout = timeout; // 设置超时（超过指定时间没有数据就退出）
        soap_->send_timeout = timeout;
        soap_->connect_timeout = timeout;

#if defined(__linux__) ||                                                      \
    defined(__linux) // 参考https://www.genivia.com/dev.html#client-c的修改：
        soap_->socket_flags =
            MSG_NOSIGNAL; // To prevent connection reset errors
#endif

        soap_set_mode(
            soap_,
            SOAP_C_UTFSTRING); // 设置为UTF-8编码，否则叠加中文OSD会乱码
    }
    ~OnvifSoap() {
        soap_destroy(
            soap_);      // deletes data, array, and other managed C++ objects
        soap_end(soap_); // delete managed memory。soap_malloc
        // soap_done(soap_); // Reset, close communications, and remove
        // callbacks
        soap_free(soap_); /* we're done with the context */
    }

    struct soap *soap() { return soap_; }

    void *Malloc(size_t n) {
        if (!n) {
            return nullptr;
        }
        // Allocate a block of heap memory managed by the specified soap context
        // All such blocks allocated are deleted with a single call to soap_end.
        auto p = soap_malloc(soap_, n);
        assert(p);
        return p;
    }

    const char *WsaRandUuid() { return soap_wsa_rand_uuid(soap_); }

    void InitHeader() {
        // T * soap_new_T(struct soap*) allocates and initializes data of type T
        // in context-managed heap memory, managed data is deleted with
        // soap_destroy (deletes C++ objects) and soap_end (deletes all other
        // data), and you can also use soap_malloc to allocate uninitialized
        // context-managed memory.
        struct SOAP_ENV__Header *header = soap_new_SOAP_ENV__Header(soap_);
        soap_default_SOAP_ENV__Header(soap_, header);

        header->wsa__MessageID = (char *)this->WsaRandUuid();
        header->wsa__To = (char *)this->Malloc(strlen(SOAP_TO) + 1);
        header->wsa__Action = (char *)this->Malloc(strlen(SOAP_ACTION) + 1);
        strcpy(header->wsa__To, SOAP_TO);
        strcpy(header->wsa__Action, SOAP_ACTION);
        soap_->header = header;
    }

    void InitProbeType(struct wsdd__ProbeType *probe) {
        // 用于描述查找哪类的Web服务
        struct wsdd__ScopesType *scope = soap_new_wsdd__ScopesType(soap_);

        soap_default_wsdd__ScopesType(soap_, scope); // 设置寻找设备的范围
        scope->__item = "";

        soap_default_wsdd__ProbeType(soap_, probe);
        probe->Scopes = scope;
        probe->Types = (char *)SOAP_COMPAT_TYPES; // 设置寻找设备的类型
    }

    int Error() { return soap_->error; }

private:
    struct soap *soap_;
};

void ONVIF_DetectDevice(void (*cb)(char *DeviceXAddr)) {
    int i;
    int result = 0;
    unsigned int count = 0;          // 搜索到的设备个数
    struct wsdd__ProbeType req;      // 用于发送Probe消息
    struct __wsdd__ProbeMatches rep; // 用于接收Probe应答
    struct wsdd__ProbeMatchType *probeMatch;

    OnvifSoap onvif_soap(SOAP_SOCK_TIMEOUT);
    onvif_soap.InitHeader();        // 设置消息头描述
    onvif_soap.InitProbeType(&req); // 设置寻找的设备的范围和类型

    result = soap_send___wsdd__Probe(onvif_soap.soap(), SOAP_MCAST_ADDR, NULL,
                                     &req); // 向组播地址广播Probe消息
    while (SOAP_OK == result) // 开始循环接收设备发送过来的消息
    {
        soap_default___wsdd__ProbeMatches(onvif_soap.soap(), &rep);
        result = soap_recv___wsdd__ProbeMatches(onvif_soap.soap(), &rep);
        if (SOAP_OK == result) {
            if (onvif_soap.Error()) {
                soap_perror(onvif_soap.soap(), "ProbeMatches");
            } else { // 成功接收到设备的应答消息
                if (NULL != rep.wsdd__ProbeMatches) {
                    count += rep.wsdd__ProbeMatches->__sizeProbeMatch;
                    for (i = 0; i < rep.wsdd__ProbeMatches->__sizeProbeMatch;
                         i++) {
                        probeMatch = rep.wsdd__ProbeMatches->ProbeMatch + i;
                        std::cout << probeMatch->XAddrs << ", "
                                  << probeMatch->Types << std::endl;
                    }
                }
            }
        } else if (onvif_soap.Error()) {
            break;
        }
    }

    SOAP_DBGLOG("\ndetect end! It has detected %d devices!\n", count);

    return;
}

int main(int argc, char **argv) {
    ONVIF_DetectDevice(nullptr);

    return 0;
}