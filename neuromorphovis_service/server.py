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

        current_directory = os.path.dirname(__file__)
        output_directory = os.path.abspath(os.path.join(current_directory, "..", "output"))

        # Ensure the meshes subdirectory exists
        meshes_directory = os.path.join(output_directory, 'meshes')
        if not os.path.exists(meshes_directory):
            os.makedirs(meshes_directory)

        script_path = os.path.abspath(os.path.join(current_directory, "..", "neuromorphovis.py"))
        blender_executable_path = os.path.abspath(os.path.join(current_directory, "..", "blender/bbp-blender-3.5/blender-bbp/blender"))

        print("Running NMV script...")

        command = [
            "python",
            script_path,
            f"--blender={blender_executable_path}",
            "--input=file",
            f"--morphology-file={temp_file_path}",
            "--export-soma-mesh-blend",
            "--export-soma-mesh-obj",
            f"--output-directory={meshes_directory}",
        ]

        subprocess.run(command, check=True)
        print("Done with NMV script.")

        print("output dir: ", output_directory)
        # FIXME This doesn't work, the returned array is empty
        generated_files = glob.glob(f"{output_directory}/meshes/*.obj")

        print("Generated files: ", generated_files)

        if not generated_files:
            raise HTTPException(status_code=404, detail="OBJ file not found after processing.")

        generated_obj_path = generated_files[0]
        print('generated_obj_path: ', generated_obj_path)
        new_obj_filename = f"{os.path.splitext(file.filename)[0]}_{short_uuid}_{timestamp}.obj"
        new_obj_path = os.path.join(output_directory, new_obj_filename)
        os.rename(generated_obj_path, new_obj_path)

        new_gltf_filename = f"{os.path.splitext(file.filename)[0]}_{short_uuid}_{timestamp}.gltf"
        print("new gltf file name: ", new_gltf_filename)
        new_gltf_path = os.path.join(output_directory, new_gltf_filename)

        print("new gltf path: ", new_gltf_path)

        conversion_command = [
            "bun", "x", # Use the bun tool to convert the OBJ to an optimized GLTF for the browser
            "obj2gltf",
            "-i", new_obj_path,
            "-o", new_gltf_path
        ]

        try:
            result = subprocess.run(conversion_command, check=True, capture_output=True, text=True)
            print(f"Conversion stdout: {result.stdout}")
            print(f"Conversion stderr: {result.stderr}")
        except subprocess.CalledProcessError as e:
            print(f"Error during conversion: {e}")
            print(f"Conversion stderr: {e.stderr}")
            raise HTTPException(status_code=500, detail="Error during conversion")

        if not os.path.exists(new_gltf_path):
            print(f"Expected GLTF file not found: {new_gltf_path}")
            raise HTTPException(status_code=404, detail="GLTF file not found after conversion.")

        return FileResponse(
            path=new_gltf_path,
            media_type="model/gltf+json",
            filename=new_gltf_filename,
        )
    finally:
        if temp_file_path and os.path.exists(temp_file_path):
            os.remove(temp_file_path)
