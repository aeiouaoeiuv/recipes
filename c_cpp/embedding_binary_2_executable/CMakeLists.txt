cmake_minimum_required(VERSION 3.15)

project(embed_binary)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_subdirectory(png)
add_subdirectory(main)

file(GLOB BINARY_OBJS "png/*.o")

add_executable(${PROJECT_NAME}
    $<TARGET_OBJECTS:main>
    ${BINARY_OBJS}
)

set_target_properties(${PROJECT_NAME} PROPERTIES LINK_OPTIONS -s) # strip

target_link_libraries(${PROJECT_NAME}
    pthread
)
