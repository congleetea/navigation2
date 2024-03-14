#!/usr/bin/env bash
#   Copyright (C) 2024 All rights reserved.
#   FileName      ：generate_nav2_lifecycle_package.sh
#   Author        ：congleetea
#   Email         ：congleetea@163.com
#   Date          ：2024年03月04日
#   Description   ：

PWD_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
ROOT_DIR=$PWD_DIR/..

help() {
	echo "--Usage: "
	echo "      ./generate_nav2_lifecycle_package.sh -p|--package <package-name> -c|--class <class-name> -a|--author <YourName>"
	echo ""
	echo "for example:"
	echo "      ./generate_nav2_lifecycle_package.sh -p planner -c Planner -a XiaoMing"
	echo "or:"
	echo "      ./generate_nav2_lifecycle_package.sh --package planner --class Planner --author XiaoMing"
	echo "will generate ros2/nav2 package: nav2_planner with class planner::Planner."
}

function echo_info(){
	echo -e "\033[37m INFO: $1 \033[0m"
}

function echo_warn(){
	echo -e "\033[34m WARN: $1 \033[0m"
}

function echo_error(){
	echo -e "\033[31m ERROR: $1 \033[0m"
}

if ! options=$(getopt -o p:c:a:h -l package:,class:,author:help -- "$@")
then
    exit 1
fi

set -- $options
package=
namespace=
class=
author=
while [ $# -gt 0 ]
do
	case $1 in
		-p|--package)
			eval namespace=$2
			eval package=nav2_$2
			shift
			;;
		-c|--class)
			eval class=$2
			shift
			;;
		-a|--author)
			eval author=$2
			shift
			;;
		-h|--help)
			help
			exit 1
			;;
		--) shift;
			break;;
		*) echo_error "Input error"
			exit 1
			;;
	esac
	shift
done
if [ -z "$package" ]; then
	help
	exit 1
fi
if [ -z "$class" ]; then
	help
	exit 1
fi
if [ "V$author" = "--" ];then
	echo_warn "author is empty, use PC USENAME: $USER"
	author=$USER
	echo ""
fi

echo "namespace: ${namespace}"
echo "package  : ${package}"
echo "class    : ${class}"
echo "author   : ${author}"
package_dir=$ROOT_DIR/$package

echo_info "root directory: $ROOT_DIR"
echo_info "package directory: $package_dir"
if [ -d $package_dir ];then
	echo_error "$package_dir has existed, cannot create this package."
	exit;
fi

# create package directory.
echo_info "create package $package in $ROOT_DIR"
mkdir $ROOT_DIR/$package
include_dir=$package_dir/include/$package
src_dir=$package_dir/src
if [ ! -d ${include_dir} ];then
	echo_info "mkdir ${include_dir}"
	mkdir -p $include_dir
fi
if [ ! -d $src_dir ];then
	echo_info "mkdir ${src_dir}"
	mkdir -p $src_dir
fi
echo_info "create package.xml"
package_xml=$package_dir/package.xml
cat>$package_xml<<EOF
<?xml version="1.0"?>
<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>
<package format="3">
  <name>$package</name>
  <version>0.0.0</version>
  <description>TODO: Package description</description>
  <maintainer email="YOUNAME@ubtrobot.com">YOURNAME</maintainer>
  <license>TODO: License declaration</license>

  <buildtool_depend>ament_cmake</buildtool_depend>

  <build_depend>rclcpp</build_depend>
  <build_depend>rclcpp_lifecycle</build_depend>
  <build_depend>nav2_util</build_depend>
  <build_depend>nav2_msgs</build_depend>

  <exec_depend>rclcpp</exec_depend>
  <exec_depend>rclcpp_lifecycle</exec_depend>
  <exec_depend>nav2_util</exec_depend>
  <exec_depend>nav2_msgs</exec_depend>

  <test_depend>ament_lint_auto</test_depend>
  <test_depend>ament_lint_common</test_depend>

  <export>
    <build_type>ament_cmake</build_type>
  </export>
</package>
EOF

echo_info "create CMakeLists.txt"
cmakelist_txt=$package_dir/CMakeLists.txt
cat>$cmakelist_txt<<EOF
cmake_minimum_required(VERSION 3.5)
project($package)

find_package(ament_cmake REQUIRED)
find_package(nav2_common REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_action REQUIRED)
find_package(rclcpp_lifecycle REQUIRED)
find_package(rclcpp_components REQUIRED)
find_package(nav2_util REQUIRED)
find_package(nav2_msgs REQUIRED)

nav2_package()

include_directories(
	include
)

set(library_name ${namespace}_lib)
set(executable_name $namespace)

set(dependencies
	rclcpp
	rclcpp_lifecycle
	rclcpp_components
	nav2_util
	nav2_msgs
)

# Library
add_library(\${library_name} SHARED
  src/$namespace.cpp
)
ament_target_dependencies(\${library_name}
  \${dependencies}
)
rclcpp_components_register_nodes(\${library_name} "$namespace::$class")

# Executable
add_executable(\${executable_name}
	src/main.cpp
)
target_link_libraries(\${executable_name} \${library_name})
ament_target_dependencies(\${executable_name}
  \${dependencies}
)


# Install
install(TARGETS \${library_name}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
)
install(TARGETS \${executable_name}
  RUNTIME DESTINATION lib/\${PROJECT_NAME}
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
ament_export_libraries(\${library_name}
)
ament_export_dependencies(\${dependencies})

ament_package()
EOF


echo_info "create header file."
hpp_txt=$include_dir/$namespace.hpp
cat>$hpp_txt<<EOF
/****************************************************************************
 *
 *   Copyright (c) 2024 UBT Robot Development Team. All rights reserved.
 *   @author $author
 *   @created `date "+%Y-%m-%d %H:%M:%S"`
 *
 ****************************************************************************/
#pragma once

#include <chrono>
#include <string>
#include <memory>
#include <vector>

#include "rclcpp/rclcpp.hpp"
#include "nav2_util/lifecycle_node.hpp"

namespace $package
{
  /**
	 * @class $class
   * @brief
   */
class $class : public nav2_util::LifecycleNode
{
public:
	  /**
	   * @brief A constructor for $class
   * @param options Additional options to control creation of the node.
	   */
	explicit $class(const rclcpp::NodeOptions & options = rclcpp::NodeOptions());
	~$class();

protected:
  /**
   * @brief Configure lifecycle server
   */
  nav2_util::CallbackReturn on_configure(const rclcpp_lifecycle::State & state) override;

  /**
   * @brief Activate lifecycle server
   */
  nav2_util::CallbackReturn on_activate(const rclcpp_lifecycle::State & state) override;

  /**
   * @brief Deactivate lifecycle server
   */
  nav2_util::CallbackReturn on_deactivate(const rclcpp_lifecycle::State & state) override;

  /**
   * @brief Cleanup lifecycle server
   */
  nav2_util::CallbackReturn on_cleanup(const rclcpp_lifecycle::State & state) override;

  /**
   * @brief Shutdown lifecycle server
   */
  nav2_util::CallbackReturn on_shutdown(const rclcpp_lifecycle::State & state) override;

};
} // namespace $package


EOF


echo_info "create source file."
cpp_txt=$package_dir/src/$namespace.cpp
cat>$cpp_txt<<EOF
/****************************************************************************
 *
 *   Copyright (c) 2024 UTB Robot Development Team. All rights reserved.
 *   @author $author
 *   @created `date "+%Y-%m-%d %H:%M:%S"`
 *
 ****************************************************************************/

#include <memory>
#include <string>
#include <vector>
#include <utility>
#include "nav2_util/node_utils.hpp"
#include "$package/$namespace.hpp"

namespace $package
{

$class::$class(const rclcpp::NodeOptions & options)
: nav2_util::LifecycleNode("$namespace", "", options)
{
	RCLCPP_INFO(get_logger(), "Creating");
	// TODO: your code.


}

$class::~$class()
{
}

nav2_util::CallbackReturn
$class::on_configure(const rclcpp_lifecycle::State & /*state*/)
{
  RCLCPP_INFO(get_logger(), "Configuring");
	// TODO: your code

  return nav2_util::CallbackReturn::SUCCESS;
}


nav2_util::CallbackReturn
$class::on_activate(const rclcpp_lifecycle::State & /*state*/)
{
  RCLCPP_INFO(get_logger(), "Activating");
	// TODO: your code

  // create bond connection
  createBond();

  return nav2_util::CallbackReturn::SUCCESS;
}

nav2_util::CallbackReturn
$class::on_deactivate(const rclcpp_lifecycle::State & /*state*/)
{
  RCLCPP_INFO(get_logger(), "Deactivating");
	// TODO: your code



  // destroy bond connection
  destroyBond();

  return nav2_util::CallbackReturn::SUCCESS;
}

nav2_util::CallbackReturn
$class::on_cleanup(const rclcpp_lifecycle::State & /*state*/)
{
  RCLCPP_INFO(get_logger(), "Cleaning up");
	// TODO: your code


  return nav2_util::CallbackReturn::SUCCESS;
}

nav2_util::CallbackReturn
$class::on_shutdown(const rclcpp_lifecycle::State &)
{
  RCLCPP_INFO(get_logger(), "Shutting down");
	// TODO: your code

  return nav2_util::CallbackReturn::SUCCESS;
}
} // end namespace $package

#include "rclcpp_components/register_node_macro.hpp"

// Register the component with class_loader.
// This acts as a sort of entry point, allowing the component to be discoverable when its library
// is being loaded into a running process.
RCLCPP_COMPONENTS_REGISTER_NODE($package::$class)
EOF

echo_info "create main.cpp file."
main_txt=$package_dir/src/main.cpp
cat>$main_txt<<EOF
/****************************************************************************
 *
 *   Copyright (c) 2024 UTB Robot Development Team. All rights reserved.
 *   @author $author
 *   @created `date "+%Y-%m-%d %H:%M:%S"`
 *
 ****************************************************************************/

#include <memory>

#include "$package/$namespace.hpp"
#include "rclcpp/rclcpp.hpp"

int main(int argc, char ** argv)
{
	rclcpp::init(argc, argv);
	auto ${namespace}_node = std::make_shared<$package::$class>();

	rclcpp::spin(${namespace}_node->get_node_base_interface());
	rclcpp::shutdown();

	return 0;
}
EOF

echo_info "Finished to create nav2 lifecycle package."
