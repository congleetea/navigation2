/****************************************************************************
 *
 *   Copyright (c) 2024 UTB Robot Development Team. All rights reserved.
 *   @author LiXuancong
 *   @created 2024-03-14 17:09:19
 *
 ****************************************************************************/

#include <memory>

#include "nav2_coverage_planner/coverage_server.hpp"
#include "rclcpp/rclcpp.hpp"

int main(int argc, char ** argv)
{
	rclcpp::init(argc, argv);
	auto coverage_planner_node = std::make_shared<nav2_coverage_planner::CoverageServer>();

	rclcpp::spin(coverage_planner_node->get_node_base_interface());
	rclcpp::shutdown();

	return 0;
}
