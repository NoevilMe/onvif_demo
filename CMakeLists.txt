cmake_minimum_required(VERSION 3.0)
project(OnvifSoap)

cmake_minimum_required(VERSION 3.10)
set(CMAKE_CXX_STANDARD 17)

add_library(
  onvif_soap STATIC
  soap/struct_timeval.cpp
  # soap/struct_tm.cpp
  soap/duration.cpp
  soap/wsaapi.cpp
  soap/soapC.cpp
  soap/soapClient.cpp
  soap/stdsoap2.cpp)
target_include_directories(onvif_soap PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(onvif_scan tests/scan_device.cpp)
target_link_libraries(onvif_scan PRIVATE onvif_soap)
target_include_directories(onvif_scan PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/soap)
