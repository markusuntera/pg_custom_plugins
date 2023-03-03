cmake_minimum_required(VERSION 3.20.0 FATAL_ERROR)
project(PGPlugins C)
set(PROJECT_NAME PGPlugins)

set(INSTALL_MAC_APP OFF)
set(MAC_APP_PATH "/Applications/Postgres.app")
set(MAC_APP_PG_VERSION "13" CACHE STRING "13")

set(CMAKE_BUILD_TYPE
    "Release"
    CACHE STRING "Release" FORCE
)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")

#set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O2")
#set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O2")

if(UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif()

if(APPLE)
    add_link_options(-bundle -flat_namespace -undefined suppress)
endif()

if(LINUX) 
    add_link_options(-fPIC)
    add_compile_options(-shared)
endif()

if(APPLE AND NOT LINUX)
    if(EXISTS "${MAC_APP_PATH}")
        set(INSTALL_MAC_APP ON)
    endif()
endif()

find_package(PROJ REQUIRED CONFIG)

message(STATUS "Proj libs: ${PROJ_LIBRARIES}")
message(STATUS "Proj INCLUDE_DIRS: ${PROJ_INCLUDE_DIRS}")

find_package(PostgreSQL REQUIRED)

message(STATUS "PostgreSQL_VERSION_STRING: ${PostgreSQL_VERSION_STRING}")
message(STATUS "PostgreSQL_LIBRARIES: ${PostgreSQL_LIBRARIES}")
message(STATUS "PostgreSQL_INCLUDE_DIRS: ${PostgreSQL_INCLUDE_DIRS}")
message(STATUS "PostgreSQL_LIBRARY_DIRS: ${PostgreSQL_LIBRARY_DIRS}")

if(PostgreSQL_FOUND)
    execute_process(COMMAND pg_config --sharedir OUTPUT_VARIABLE PostgreSQL_SHAREDIR)
    string(STRIP ${PostgreSQL_SHAREDIR} PostgreSQL_SHAREDIR)
    message(STATUS "PostgreSQL_SHAREDIR=${PostgreSQL_SHAREDIR}")
endif()

file(GLOB RESOURCES ${PROJECT_SOURCE_DIR}/resources/eyevigis*)

SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

set(INCLUDES
    ${PROJ_INCLUDE_DIRS}
    ${PostgreSQL_INCLUDE_DIRS}
)

if(INSTALL_MAC_APP)
    set(INCLUDES 
        "${MAC_APP_PATH}/Contents/Versions/${MAC_APP_PG_VERSION}/include/postgresql/server/"
        ${INCLUDES}
    )
endif()
#set(PROJ_LIBRARIES "/usr/local/lib/libproj.dylib")

set(LIBRARIES
    ${PROJ_LIBRARIES}
)

INCLUDE_DIRECTORIES(${INCLUDES})

add_library(pg_eyevigis MODULE
    src/pg_eyevigis.c
)

message(STATUS "LIBS: ${LIBRARIES}")

set_target_properties(pg_eyevigis PROPERTIES PREFIX "")
target_include_directories(pg_eyevigis PRIVATE ${INCLUDES})
target_link_libraries(pg_eyevigis PRIVATE ${LIBRARIES})

INSTALL(TARGETS pg_eyevigis DESTINATION ${PostgreSQL_LIBRARY_DIRS} CONFIGURATIONS Release)
if(PostgreSQL_SHAREDIR)
    INSTALL(FILES ${RESOURCES}
        DESTINATION ${PostgreSQL_SHAREDIR}/extension CONFIGURATIONS Release)
endif()

if(INSTALL_MAC_APP)
    INSTALL(TARGETS pg_eyevigis 
        DESTINATION "${MAC_APP_PATH}/Contents/Versions/${MAC_APP_PG_VERSION}/lib/postgresql" CONFIGURATIONS Release)
    INSTALL(FILES ${RESOURCES}
        DESTINATION "${MAC_APP_PATH}/Contents/Versions/${MAC_APP_PG_VERSION}/share/postgresql/extension" )
endif()