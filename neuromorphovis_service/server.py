from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import FileResponse
import subprocess
import os
import shutil
from tempfile import NamedTemporaryFile
import glob
import uuid
from datetime import datetime

app = FastAPI()


@app.get("/health")
async def health():
    return {"status": "OK"}


@app.post("/process-swc")
async def process_swc(file: UploadFile = File(...)):
    # Generate a short UUID and timestamp
    short_uuid = uuid.uuid4().hex[:8]
    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    # Prepare the temporary file
    temp_file_path = ""
    try:
        with NamedTemporaryFile(delete=False, suffix=".swc") as temp_file:
            shutil.copyfileobj(file.file, temp_file)
            temp_file_path = temp_file.name

        # Define paths
        current_directory = os.path.dirname(__file__)
        output_directory = os.path.join(current_directory, "..", "output", "meshes")
        script_path = os.path.abspath(
            os.path.join(current_directory, "..", "neuromorphovis.py")
        )
        blender_executable_path = os.path.abspath(
            os.path.join(
                current_directory, "..", "blender/bbp-blender-3.5/blender-bbp/blender"
            )
        )

        # Define Blender command
        command = [
            "python",
            script_path,
            f"--blender={blender_executable_path}",
            "--input=file",
            f"--morphology-file={temp_file_path}",
            "--export-soma-mesh-blend",
            "--export-soma-mesh-obj",
            f"--output-directory={os.path.join(current_directory, '..', 'output')}",
        ]

        # Execute the command
        subprocess.run(command, check=True)

        # Check for the generated .obj file
        generated_files = glob.glob(f"{output_directory}/*.obj")
        if not generated_files:
            raise HTTPException(
                status_code=404, detail="OBJ file not found after processing."
            )

        generated_obj_path = generated_files[0]
        new_obj_filename = f"{os.path.splitext(file.filename)[0]}_{short_uuid}_{timestamp}.obj"
        new_obj_path = os.path.join(output_directory, new_obj_filename)
        os.rename(generated_obj_path, new_obj_path)

        # Convert .obj to .gltf
        new_gltf_filename = f"{os.path.splitext(file.filename)[0]}_{short_uuid}_{timestamp}.gltf"
        new_gltf_path = os.path.join(output_directory, new_gltf_filename)
        conversion_command = [
            "bun", "x",
            "obj2gltf",
            "-i", new_obj_path,
            "-o", new_gltf_path
        ]
        subprocess.run(conversion_command, check=True)

        # Cleanup
        files = glob.glob(f"{output_directory}/*")
        for f in files:
            if f != new_gltf_path:  # Keep only the newly converted .gltf file
                os.remove(f)

        return FileResponse(
            path=new_gltf_path,
            media_type="model/gltf+json",
            filename=new_gltf_filename,
        )
    finally:
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)
