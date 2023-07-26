import argparse
import pymeshlab as ml
from pathlib import Path


class Mesh():
    def __init__(self, F, V):
        self.F = F
        self.V = V
        self.n_faces = self.F.shape[0]
        self.n_vertices = self.V.shape[0]


def read_mesh_from_file(filename):
    ms = ml.MeshSet()
    # Read the file, with good error handling
    try:
        ms.load_new_mesh(filename)
    except(ml.PyMeshLabException) as e:
        if "File does not exist" in str(e):
            raise ValueError(f"'{filename}' was not found.") from e
        elif "Unknown format for load" in str(e):
            raise ValueError(f"File '{filename}' was not of any known mesh type.") from e
    F = ms.current_mesh().face_matrix()
    V = ms.current_mesh().vertex_matrix()
    
    # Handle case where the file was read but no faces or vertices were parsed
    if len(V) == 0:
        raise ValueError(f"File '{filename}' contained an empty or misformatted mesh.")
    
    mesh = Mesh(F, V)
    return mesh


def write_mesh_to_dat_files(mesh, F_filename="Faces.dat", V_filename="Vertices.dat"):
    with open(F_filename, 'w') as f:
        f.write(f"{mesh.n_faces:10d}\n")
        for v1, v2, v3 in mesh.F.astype(int):
            f.write(f"{v1:10d} {v2:11d} {v3:11d}\n")
    with open(V_filename, 'w') as f:
        f.write(f"{mesh.n_vertices:10d}\n")
        for x, y, z in mesh.V.astype(float):
            f.write(f"{x:30.18f} {y:30.18f} {z:30.18f}\n")



def get_mesh_files():
    mesh_extensions = ['.ply', '.stl', '.off', '.obj']
    current_directory = Path.cwd()
    files_found = []
    for file_path in current_directory.iterdir():
        if file_path.suffix.lower() in mesh_extensions:
            files_found.append(file_path.name)
    return files_found

def get_filename(args):
    # If the user provided a mesh file then use it, else try to find one
    if args.file and Path(args.file).exists():
        filename = args.file
    else:
        print("No mesh file provided. Looking for mesh files in current directory...")
        meshes = get_mesh_files()

        # If there is only one mesh file in the current directory, use it
        if len(meshes) == 1:
            print(f"Found mesh file {meshes[0]}.")
            filename = meshes[0]

        # If there are no mesh files in the current directory, prompt the user for a file path
        elif len(meshes) == 0:
            print("No mesh files found in current directory.")
            while True:
                user_input = input("Please enter the path to a mesh file or press 'q' to exit: ")
                if user_input.lower() == 'q' or user_input.lower() == 'quit':
                    exit()
                
                if Path(user_input).exists():
                    filename = user_input
                    break
                else:
                    print("Invalid file path. Please try again.")

        # If there are multiple mesh files in the current directory, prompt the user to select one
        else:
            print("Multiple mesh files found in current directory.")
            while True:
                print("Please select a mesh file from the list below or press 'q' to exit:")
                for i, mesh in enumerate(meshes):
                    print(f"{i+1}: {mesh}")
                user_input = input()
                if user_input.lower() == 'q' or user_input.lower() == 'quit':
                    exit()
                try:
                    filename = meshes[int(user_input)-1]
                    break
                except:
                    print("Invalid selection. Please try again.")
    
    return filename


def main():
    parser = argparse.ArgumentParser(
        description="Read in a mesh and write it to Faces.dat and Vertices.dat files for use in BEM solver.")
    parser.add_argument('-f', '--file', help="Path to mesh file to read.")    
    args = parser.parse_args()

    filename = get_filename(args)
    print(f"Reading mesh from {filename}...")
    mesh = read_mesh_from_file(filename)
    print(f"Writing mesh to Faces.dat and Vertices.dat...")
    write_mesh_to_dat_files(mesh)
    print("Finished.")

if __name__ == "__main__":
    main()