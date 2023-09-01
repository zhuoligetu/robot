FROM ubuntu:18.04

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


RUN apt-get update

# unminimize ubuntu
RUN yes | unminimize

# config CN environment
RUN apt install language-pack-zh-hans -y

RUN echo LANG="zh_CN.UTF-8" >> /etc/environment
RUN echo LANGUAGE="zh_CN:zh:en_US:en" >> /etc/environment

RUN echo LANG="zh_CN.UTF-8" >> /etc/profile
RUN echo LANGUAGE="zh_CN:zh:en_US:en" >> /etc/profile

RUN echo LANG="zh_CN.UTF-8" >> ~/.bashrc
RUN echo LANGUAGE="zh_CN:zh:en_US:en" >> ~/.bashrc

RUN locale-gen
RUN /bin/bash -c "source ~/.bashrc"

# install xfce4
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y xfce4 xfce4-terminal
RUN apt install unzip -y
RUN apt install dbus-x11 -y
RUN apt install -y libusb-1.0-0-dev
RUN apt install -y net-tools
RUN apt install fonts-wqy-microhei -y
RUN apt install -y \
    gnome-user-docs-zh-hans \
    language-pack-gnome-zh-hans \
    fcitx \
    fcitx-pinyin \
    fcitx-table-wubi \
    vim
    
# 安装ROS Melodic
RUN apt update && \
    apt install -y curl gnupg2 lsb-release && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros1-latest.list && \
    apt update && \
    apt install -y ros-melodic-desktop-full && \
    apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential && \
    rm -rf /var/lib/apt/lists/*
# install rosparam-shortcuts:
RUN apt-get update
RUN apt-get install -y \
    ros-melodic-move-base-msgs \
    libsdl-image1.2-dev \
    ros-melodic-serial \
    ros-melodic-sparse-bundle-adjustment \
    ros-melodic-tf2-sensor-msgs \
    ros-melodic-geographic-msgs \
    ros-melodic-bfl

# install ceres:
COPY ./thirdparty /thirdparty

RUN apt install -y \
    libgoogle-glog-dev \
    libgflags-dev 

RUN cd /thirdparty && \
    unzip ceres-solver.zip && \
    cd ceres-solver && mkdir build && cd build && cmake .. &&  make -j8 && \
    make install

# install slamtoolbox
RUN cd /thirdparty && \
    chmod +x ./ros-melodic-slamoptomapping-dep_1.1.0-0bionic_amd64.deb && \
    dpkg -i ./ros-melodic-slamoptomapping-dep_1.1.0-0bionic_amd64.deb

# install mrpt
RUN cd /thirdparty && \
    unzip mrpt-mrpt-1.5.zip && \
    cd mrpt-mrpt-1.5 && mkdir build && cd build && cmake .. &&  make -j8 && \
    make install


RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
# 设置环境变量
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV ROS_DISTRO melodic

# 将一些文件放入/usr/lib/里面
COPY ./lib /usr/local/lib

# set up vnc
RUN apt-get install tigervnc-standalone-server x11vnc -y
WORKDIR /root/.vnc
COPY ./docker/xstartup ./
RUN chmod u+x ~/.vnc/xstartup

RUN cd /thirdparty && \ 
    mv ./noVNC.zip /usr/lib && \
    cd /usr/lib &&\
    unzip noVNC.zip &&\
    rm noVNC.zip

RUN cd /thirdparty && \ 
    mv ./websockify.zip /usr/lib/noVNC/utils && \
    cd /usr/lib/noVNC/utils &&\
    unzip websockify.zip &&\
    rm -r websockify.zip
    
WORKDIR /
COPY ./docker/startup.sh ./
RUN chmod u+x startup.sh
ENTRYPOINT ["./startup.sh"]
# 设置启动命令
CMD ["bash"]
