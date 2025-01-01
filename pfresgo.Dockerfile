FROM tensorflow/tensorflow:2.4.1-gpu

USER root
RUN apt-get update
RUN apt-get install openssh-server sudo curl tmux -y
ARG PORT=65142

# change port and allow root login
RUN echo "Port ${PORT}" >> /etc/ssh/sshd_config
# RUN echo "LogLevel DEBUG3" >> /etc/ssh/sshd_config

RUN mkdir -p /run/sshd
RUN ssh-keygen -A

RUN service ssh start

# init conda env
RUN curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
RUN bash Miniforge3-$(uname)-$(uname -m).sh -b -f
RUN mamba init
RUN mamba install numpy -y
RUN pip install --no-cache-dir -q lightning click transformers goatools toml wget fastobo pydantic loguru wandb tqdm einops wandb obonet fastobo h5py seaborn scikit-learn pydantic

RUN apt-get install git -y

EXPOSE ${PORT}

CMD ["/usr/sbin/sshd","-D", "-e"]