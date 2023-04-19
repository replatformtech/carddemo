import os

if "OKDIR" not in os.environ:
    print("OKDIR is not set")
    Exit(2)

SConscriptChdir(0)
SConscript(os.environ["OKDIR"] + "/python/scons/SConscript1.py")

