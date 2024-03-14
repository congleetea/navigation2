# An ordered set of swaths (if route generated) and turns (if path generated)
std_msgs/Header header
nav2_msgs/Swath[] swaths
nav_msgs/Path[] turns
bool contains_turns
bool swaths_ordered
