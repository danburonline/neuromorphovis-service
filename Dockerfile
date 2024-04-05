# Use the Python base image
FROM --platform=linux/amd64 python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set work directory
WORKDIR /app

# Install necessary libraries for Blender, wget, xz-utils, and libSM
RUN apt-get update && apt-get install -y \
  wget \
  unzip \
  curl \
  libxi6 \
  libgl1 \
  libsm6 \
  xz-utils \
  libxfixes3 \
  libxrender1 \
  libdbus-1-3 \
  libxkbcommon0 \
  && rm -rf /var/lib/apt/lists/*

# Install Bun directly to a global location
RUN curl -fsSL https://bun.sh/install | bash
# Move Bun to a global location
RUN mv /root/.bun/bin/bun /usr/local/bin/

# Ensure the ENV PATH is correctly set
ENV PATH="/usr/local/bin:${PATH}"

# Now, Bun should be available globally; you can check with:
RUN bun --version

# Install Neuromorphovis setup script
RUN wget https://raw.githubusercontent.com/BlueBrain/NeuroMorphoVis/master/setup.py
RUN chmod +x setup.py

# Create a folder called "blender" in /usr/local
RUN mkdir blender

# Create an output folder for the converted files
RUN mkdir output

# Change the access permissions of the folder to 777
RUN chmod 777 blender

# Run NeuroMorphoVis installation script
RUN python ./setup.py --prefix=./blender --verbose

# Add Blender to the PATH
ENV PATH="/app/blender/bbp-blender-3.5/blender-bbp:${PATH}"

# Install Git
RUN apt-get update && apt-get install -y git

# Clone the specific branch of NeuroMorphoVis repo to temp directory
RUN git clone --depth 1 https://github.com/BlueBrain/NeuroMorphoVis.git /temp/NeuroMorphoVis

# Copy the nmv directory to the /app directory
RUN cp -r /temp/NeuroMorphoVis/nmv /app/

# Also copy neuromorphovis.py to the /app directory
RUN cp /temp/NeuroMorphoVis/neuromorphovis.py /app/

# Clean up
RUN rm -rf /temp/NeuroMorphoVis
RUN apt-get remove -y git && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# Make neuromorphovis.py executable
RUN chmod +x neuromorphovis.py

# Install Poetry for managing dependencies
RUN pip install poetry==1.7.1

# Configure Poetry: Do not create a virtual environment
RUN poetry config virtualenvs.create false

# Copy only the necessary files for installing dependencies
COPY pyproject.toml poetry.lock* /app/

# Install project dependencies using Poetry
RUN poetry install --no-root --only main

# Copy the rest of your project files into the container
COPY . /app

RUN mkdir /app/dist

# Expose port to access the FastAPI server
EXPOSE 8000

# Run the server via Uvicorn
CMD ["uvicorn", "neuromorphovis_service.server:app", "--host", "0.0.0.0", "--port", "8000"]
