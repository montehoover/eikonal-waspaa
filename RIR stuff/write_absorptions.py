# The first line of Faces.dat contains the number of faces in the mesh. Read it.
print("Reading number of mesh faces from Faces.dat...")
with open("Faces.dat") as f:
    try:
        num_faces = int(f.readline())
    except ValueError as e:
        print("Error: First line of Faces.dat should be the number of faces in the mesh.")
        raise e

# Create Absorptions.dat with one line per face of the mesh, each containing that face's
# absorption value. Use 0.64 as a default.
print("Writing absorption values to Absorptions.dat...")
with open("Absorptions.dat", "w") as f:
    for i in range(num_faces):
        print("6.400000000000000e-01", file=f)

print("Finished.")