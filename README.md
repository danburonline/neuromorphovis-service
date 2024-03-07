# NeuroMorphoVis as a Service

This repository contains a proof of concept for a Python web server to run the open-source [NeuroMorphoVis](https://github.com/BlueBrain/NeuroMorphoVis) tool as a cloud service. It allows for physics-based reconstructions of neuronal soma cells and other morphological processes for analysis and simulations.

## Example CLI script

```bash
python neuromorphovis.py --input=file --morphology-file=/files/example-morphology.swc --export-soma-mesh-blend --export-soma-mesh-obj --output-directory=./output
```
