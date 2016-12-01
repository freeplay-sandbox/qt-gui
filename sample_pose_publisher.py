#!/usr/bin/env python
import rospy
import time
from geometry_msgs.msg import PoseStamped

def talker():
    pub = rospy.Publisher('poses', PoseStamped, queue_size=10)
    rospy.init_node('sample_pose_publisher', anonymous=True)
    rate = rospy.Rate(10) # 10hz

    pose = PoseStamped()
    pose.header.frame_id="sandtray"
    pose.pose.position.y = -0.2

    x = 0.1

    while not rospy.is_shutdown():
        pose.pose.position.x = x
        pub.publish(pose)

        x += 0.005

        if x >= 0.5:
            time.sleep(2)
            x = 0.1

        rate.sleep()

if __name__ == '__main__':
    try:
        talker()
    except rospy.ROSInterruptException:
        pass

