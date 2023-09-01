FROM ubuntu:16.04

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装ROS kinetic
RUN apt update && \
    apt install -y curl gnupg2 lsb-release && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros1-latest.list && \
    apt update && \
    apt install -y ros-kinetic-desktop-full && \
    apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
# 设置环境变量
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO kinetic


# 设置启动命令
CMD ["bash"]
