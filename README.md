# NeuroMorphoVis as a Service

This repository contains a proof of concept for a Python web server to run the open-source [NeuroMorphoVis](https://github.com/BlueBrain/NeuroMorphoVis) tool as a cloud service. It allows for physics-based reconstructions of neuronal soma cells and other morphological processes for analysis and simulations.

## Quick Setup

1. Build the Docker container: `docker build -t neuromorphovis .`
2. Run the Docker container: `docker run -p 8000:8000 neuromorphovis`
3. Access the web server at `http://localhost:8000/health`
4. CD into the Docker container and run CLI scripts.

## Example CLI Script

```bash
python neuromorphovis.py --blender=blender/bbp-blender-3.5/blender-bbp/blender --input=file --morphology-file=files/example-morphology.swc --export-soma-mesh-blend --export-soma-mesh-obj --output-directory=$(pwd)/output
```
