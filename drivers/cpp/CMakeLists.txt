cmake_minimum_required(VERSION 3.27)
project(XTSpeedo)



set(CMAKE_CXX_STANDARD 11)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)


find_package(SaxonCEE 12.9.0 EXACT REQUIRED)

add_executable(CppSaxonCDriver main.cpp)
# Require C++ standard
target_compile_features(CppSaxonCDriver PUBLIC cxx_std_11)
target_link_libraries(CppSaxonCDriver PRIVATE SaxonCEE::saxonc-ee)