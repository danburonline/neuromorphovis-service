# NeuroMorphoVis as a Service

This repository contains a proof of concept for a Python web server to run the open-source [NeuroMorphoVis](https://github.com/BlueBrain/NeuroMorphoVis) tool as a cloud service. It allows for physics-based reconstructions of neuronal soma cells and other morphological processes for analysis and simulations.

## Quick Setup

1. Build the Docker container: `docker build -t neuromorphovis .`
2. Run the Docker container: `docker run -p 8000:8000 neuromorphovis`
3. Access the web server at `http://localhost:8000/health`
4. CD into the Docker container and run CLI scripts.

### Example CLI Script

```bash
python neuromorphovis.py --blender=blender/bbp-blender-3.5/blender-bbp/blender --input=file --morphology-file=files/example-morphology.swc --export-soma-mesh-blend --export-soma-mesh-obj --output-directory=$(pwd)/output
```

## ⚠️ Quick Fixes

- Currently there is a bug in the NeuroMorphoVis addon related to the topology re-tesselation as reported [here](https://github.com/BlueBrain/NeuroMorphoVis/issues/208). Due to this the CLI command `--export-soma-mesh-obj` will not work as expected. To fix this, you need to manually comment out the following lines in the `neuromorphovis.py` script:

```python
self.mesh.topology_tessellation = nmv.enums.Meshing.TopologyTessellation.get_enum(
     arguments.topology_tessellation)
```

Afterwards, this quick fix will allow you to export the soma mesh as an OBJ file.

## How to Work with the API

When you start the Docker container a FastAPI web server will boot up and be available under `http://localhost:8000`. You'll find Hoppscotch API requests inside the [`docs`](/docs/api-specs.json) directory as a JSON that you can import into the [Hoppscotch](https://hoppscotch.io) app. This will allow you to interact with the API and run the CLI scripts from the web interface.
