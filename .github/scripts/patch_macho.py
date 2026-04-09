import os
import sys
import lief

exe = os.environ["EXECUTABLE_PATH"]
binary = lief.parse(exe)

if binary is None:
    raise RuntimeError(f"Failed to parse Mach-O: {exe}")

dylibs = [x for x in os.environ.get("DYLIBS", "").split(",") if x]
frameworks = [x for x in os.environ.get("FRAMEWORKS", "").split(",") if x]

for lib in dylibs:
    path = f"@executable_path/Frameworks/{lib}"
    print(f"Inject dylib: {path}")
    binary.add_library(path)

for fw in frameworks:
    name = fw.replace(".framework", "")
    path = f"@executable_path/Frameworks/{fw}/{name}"
    print(f"Inject framework: {path}")
    binary.add_library(path)

binary.write(exe)
