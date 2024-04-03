# Use the Python base image optimized for devcontainers
FROM mcr.microsoft.com/devcontainers/python:3.10

# Set work directory
WORKDIR /app

# TODO Add these instructions to the `post_create.sh` file

# Install necessary libraries for Blender, wget, xz-utils, and libSM
# Plus, install common development tools like vim, lsof, and others if needed
RUN apt-get update && apt-get install -y \
  wget \
  libxi6 \
  libgl1 \
  libsm6 \
  xz-utils \
  libxfixes3 \
  libxrender1 \
  libdbus-1-3 \
  libxkbcommon0 \
  vim \
  lsof \
  curl \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Neuromorphovis setup script
RUN wget https://raw.githubusercontent.com/BlueBrain/NeuroMorphoVis/master/setup.py
RUN chmod +x setup.py

# Create and prepare the Blender directory
RUN mkdir blender && chmod 777 blender

# Run NeuroMorphoVis installation script
RUN python ./setup.py --prefix=./blender --verbose

# Add Blender to the PATH
ENV PATH="/app/blender/bbp-blender-3.5/blender-bbp:${PATH}"

# Clone the specific branch of the NeuroMorphoVis repo to a temp directory
RUN git clone --depth 1 https://github.com/BlueBrain/NeuroMorphoVis.git /temp/NeuroMorphoVis

# Copy the nmv directory and neuromorphovis.py to the /app directory
RUN cp -r /temp/NeuroMorphoVis/nmv /app/ && \
  cp /temp/NeuroMorphoVis/neuromorphovis.py /app/ && \
  chmod +x /app/neuromorphovis.py && \
  rm -rf /temp/NeuroMorphoVis

# Copy the rest of your project files into the container
COPY . /app