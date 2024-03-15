cmake_minimum_required(VERSION 3.5)
project(nav2_coverage_planner)

find_package(ament_cmake REQUIRED)
find_package(nav2_common REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_action REQUIRED)
find_package(rclcpp_lifecycle REQUIRED)
find_package(rclcpp_components REQUIRED)
find_package(nav2_util REQUIRED)
find_package(nav2_msgs REQUIRED)
find_package(std_msgs REQUIRED)
find_package(visualization_msgs REQUIRED)
find_package(nav_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(builtin_interfaces REQUIRED)
find_package(tf2_ros REQUIRED)
find_package(Fields2Cover REQUIRED)

nav2_package()

include_directories(
	include
)

set(library_name coverage_planner_lib)
set(executable_name coverage_planner)

set(dependencies
	rclcpp
	rclcpp_lifecycle
	rclcpp_components
	nav2_util
	nav2_msgs
  std_msgs
  visualization_msgs
  nav_msgs
  geometry_msgs
  builtin_interfaces
  tf2_ros
)

# Library
add_library(${library_name} SHARED
  src/coverage_server.cpp
  src/headland_generator.cpp
  src/path_generator.cpp
  src/route_generator.cpp
  src/swath_generator.cpp
  src/visualizer.cpp
)
ament_target_dependencies(${library_name}
  ${dependencies}
)
target_link_libraries(${library_name} Fields2Cover)

rclcpp_components_register_nodes(${library_name} "nav2_coverage_planner::CoverageServer")

# Executable
add_executable(${executable_name}
	src/main.cpp
)
target_link_libraries(${executable_name} ${library_name})
ament_target_dependencies(${executable_name}
  ${dependencies}
)


# Install
install(TARGETS ${library_name}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)
install(TARGETS ${executable_name}
  RUNTIME DESTINATION lib/${PROJECT_NAME}
)
install(DIRECTORY include/
  DESTINATION include/
)

# Test
# if(BUILD_TESTING)
#   find_package(ament_lint_auto REQUIRED)
#   ament_lint_auto_find_test_dependencies()
#   find_package(ament_cmake_gtest REQUIRED)
#   add_subdirectory(test)
# endif()

# Export
ament_export_include_directories(include)
ament_export_libraries(${library_name}
)
ament_export_dependencies(${dependencies})

ament_package()
