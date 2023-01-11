project(png)

set(CMAKE_LD ld)

file(GLOB SRC_FILES "*.png")

foreach(ITEM ${SRC_FILES})
    get_filename_component(FILENAME ${ITEM} NAME)
    string(REGEX REPLACE "[.]png" ".o" OBJ ${FILENAME})
    execute_process(
        COMMAND ${CMAKE_LD} -r -b binary -o ${OBJ} ${FILENAME}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE RET
    )
    if(NOT RET EQUAL "0")
        message(FATAL_ERROR "${CMAKE_LD} ${OBJ} failed")
    endif()
    list(APPEND OBJ_FILES ${OBJ})
endforeach()

add_library(${PROJECT_NAME} STATIC ${OBJ_FILES})

set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
