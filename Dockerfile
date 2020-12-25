# base image
FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

RUN rm -rf /etc/apt/sources.list.d/*
RUN rm -f /etc/apt/sources.list
COPY ./sources.list /etc/apt/sources.list
RUN apt-get  clean
RUN apt-get update -y
RUN apt-get install vim screen wget -y

RUN wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh
# COPY ./Miniconda3-py37_4.9.2-Linux-x86_64.sh ./Miniconda3-py37_4.9.2-Linux-x86_64.sh
RUN bash ./Miniconda3-py37_4.9.2-Linux-x86_64.sh -b -p /usr/local/miniconda3 && rm ./Miniconda3-py37_4.9.2-Linux-x86_64.sh
# 环境变量的配置
ENV PATH=/usr/local/miniconda3/bin:$PATH
# RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple
RUN pip install numpy scipy matplotlib scikit-learn pandas jupyter notebook requests
RUN pip install jupyterlab
RUN jupyter lab --generate-config
COPY ./jupyter_lab_config.py /root/.jupyter/jupyter_lab_config.py

# install pytorch
# COPY ./torch-1.7.1+cu110-cp37-cp37m-linux_x86_64.whl /root/torch-1.7.1+cu110-cp37-cp37m-linux_x86_64.whl
# RUN pip install /root/torch-1.7.1+cu110-cp37-cp37m-linux_x86_64.whl
# RUN rm -f /root/torch-1.7.1+cu110-cp37-cp37m-linux_x86_64.whl
RUN pip install torch==1.7.1+cu110 torchvision==0.8.2+cu110 torchaudio===0.7.2 -f https://download.pytorch.org/whl/torch_stable.html

# install tensorflow
RUN pip install tensorflow

# install transformers
RUN pip install transformers

# 设置pip为ali源
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple

# ssh config
RUN apt-get install ssh -y
RUN mkdir /var/run/sshd
# RUN sed -i 's/#Port 22/Port 2222/g' /etc/ssh/sshd_config
RUN echo "root:pi@3.1415926" | chpasswd
RUN sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# 对外暴露22端口
EXPOSE 22 8888

# 在环境变量的配置文件中追加环境变量内容
RUN sed -i '$a\export CONDA_HOME="/usr/local/miniconda3"' ~/.bashrc
RUN sed -i '$a\export PATH=$CONDA_HOME/bin:$PATH' ~/.bashrc
# RUN source ~/.bashrc

# 将默认的命令设置为启动sshd服务
CMD ["/usr/sbin/sshd", "-D"]
