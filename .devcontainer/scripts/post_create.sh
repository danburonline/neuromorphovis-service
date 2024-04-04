#!/bin/bash

# Modify permissions on the virtual env
chmod -R 777 .venv

# Configure Poetry to use local virtual envs
poetry config virtualenvs.in-project true

# Install dependencies
poetry install

# NeuroMorphoVis installation
wget https://raw.githubusercontent.com/BlueBrain/NeuroMorphoVis/master/setup.py
chmod +x setup.py

chmod -R 777 blender

python ./setup.py --prefix=./blender --verbose

echo 'export PATH="/workspace/blender/bbp-blender-3.5/blender-bbp:${PATH}"' >> ~/.bashrc
source ~/.bashrc

# Create temporary folder for NeuroMorphoVis Python file installation
mkdir temp
chmod 777 temp

mkdir output
chmod 777 output

git clone --depth 1 https://github.com/BlueBrain/NeuroMorphoVis.git temp/NeuroMorphoVis

cp -r temp/NeuroMorphoVis/nmv . &&
  cp temp/NeuroMorphoVis/neuromorphovis.py . &&
  chmod +x neuromorphovis.py &&
  rm -rf temp/NeuroMorphoVis
