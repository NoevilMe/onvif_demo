cmake_minimum_required(VERSION 3.0)
project(OnvifSoap)

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_CXX_FLAGS "-g -O0")

set(LIB_SOAP_SRC
    soap/struct_timeval.cpp
    soap/duration.cpp
    soap/wsaapi.cpp
    soap/dom.cpp
    soap/wsseapi.cpp
    soap/smdevp.cpp
    soap/mecevp.cpp
    soap/threads.cpp
    soap/stdsoap2.cpp)

add_library(onvif_soap STATIC ${LIB_SOAP_SRC})
target_link_libraries(onvif_soap PUBLIC ssl crypto)
target_compile_definitions(onvif_soap PUBLIC WITH_OPENSSL WITH_DOM)
target_include_directories(onvif_soap PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/onvif)

add_library(onvif STATIC onvif/soapC.cpp onvif/soapClient.cpp)
target_include_directories(onvif PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(onvif PUBLIC onvif_soap)

add_executable(dev_scan tests/scan_device.cpp)
target_link_libraries(dev_scan PRIVATE onvif)

add_executable(dev_info tests/get_device_information.cpp)
target_link_libraries(dev_info PRIVATE onvif)
