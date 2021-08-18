FROM python:3.9-slim-buster AS StageBase

# Set environment variables - Prevents *.pyc files created, and outputs messages straight to terminal
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install System Dependencies
RUN apt -qq update && apt -qq install ffmpeg -y

# Create another stage in this build
FROM StageBase AS StageAppPrep

# Create Container user with same UID / GID as the one running docker, so we don't need to modify file permissions
# Ref - https://stackoverflow.com/a/44683248/11295787
ENV USERNAME=ydluser
ENV UID=1000
ENV GID=1000
##ARG USERNAME=ydluser
##ARG UID=1000
##ARG GID=1000
RUN \
    echo "User ID: $UID - Group ID: $GID" && \
    groupadd --gid $GID --non-unique $USERNAME && \
    useradd --create-home --uid $UID --gid $GID --non-unique --shell /bin/bash $USERNAME

# This will automatically creat the directory & switch to it.
ENV WorkingDir=/opt/ydl_api
##ARG WorkingDir=/opt/ydl_api
WORKDIR $WorkingDir

# Create another stage in this build
FROM StageAppPrep AS StageAppReady

# Bring Project Files into Docker Image
COPY . .

# Update folder ownership
RUN chown -R $USERNAME:$USERNAME $WorkingDir

# Make launch script executable
RUN chmod +x /opt/ydl_api/launch.sh

# Expose port
ENV PORT 5011
EXPOSE $PORT

# Alias for user's download directory, so it can be mounted as a volume
#ARG OutputDir=/output
#RUN mkdir -p /home/$USERNAME/downloads && \
#    chown $USERNAME:$USERNAME /home/$USERNAME/downloads && \
#    ln -s /home/$USERNAME/downloads $OutputDir && \
#    chown -h $USERNAME:$USERNAME $OutputDir
ARG OutputDir=/output
ARG LogsDir=/logs
RUN \
    mkdir -p downloads && chown $USERNAME:$USERNAME downloads && \
    ls -la $WorkingDir/down* && \
    ls -la $WorkingDir && \
    ln -s $WorkingDir/downloads/ $OutputDir && \
    chown -h $USERNAME:$USERNAME $OutputDir && \
    install -d -m 0755 -o $USERNAME -g $USERNAME $WorkingDir/logs/ && \
    ln -s $WorkingDir/logs/ $LogsDir && \
    chown -h $USERNAME:$USERNAME $LogsDir

# Run program. This is the same command as in the "ExecStart" section of the ydl_api.service file
RUN echo "Username: $USERNAME"
USER $USERNAME

# Install Python Dependencies
#COPY requirements.txt /tmp
#RUN pip3 install --upgrade pip3
RUN pip3 install --user fastapi youtube-dl uvicorn --upgrade && \
    pip3 install --user psutil --upgrade && \
    pip3 install --user aiofiles --upgrade

ENV PATH="/home/$USERNAME/.local/bin:${PATH}"
    
RUN echo "ID: $(id)"
CMD ["/opt/ydl_api/launch.sh"]
#CMD ["su", "-", "$USERNAME", "-c", "/opt/ydl_api/launch.sh"]