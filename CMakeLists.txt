cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)
project(PGPlugins C)
set(PROJECT_NAME PGPlugins)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")


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
    

set(CMAKE_CONFIGURATION_TYPES
    "Debug"
    "Release"
    CACHE STRING "" FORCE
)

SET(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin)

set(INCLUDES
    /usr/local/include/
    /Applications/Postgres.app/Contents/Versions/13/include/postgresql/server/
)

INCLUDE_DIRECTORIES(${INCLUDES})

set(PROJ_LIBRARY "/usr/local/lib/libproj.dylib")

add_library(pg_custom_plugins MODULE
    src/pg_custom_plugins.c
)
set_target_properties(pg_custom_plugins PROPERTIES PREFIX "")
target_include_directories(pg_custom_plugins PRIVATE ${INCLUDES})
target_link_libraries(pg_custom_plugins PRIVATE ${PROJ_LIBRARY})