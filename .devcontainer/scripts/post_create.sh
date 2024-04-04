#!/bin/bash

# Install Poetry
curl -sSL https://install.python-poetry.org | python - --version 1.8.2

# Configure Poetry to use local virtual envs
poetry config virtualenvs.in-project true

# Modify permissions on the virtual env
sudo chmod -R 777 .venv

# Install dependencies
poetry install

# NeuroMorphoVis installation
wget https://raw.githubusercontent.com/BlueBrain/NeuroMorphoVis/master/setup.py
chmod +x setup.py

sudo chmod -R 777 blender

python ./setup.py --prefix=./blender --verbose
PATH="/workspace/blender/bbp-blender-3.5/blender-bbp:${PATH}"

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

# activate the virtual environment
poetry shell