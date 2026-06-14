import sys, os, subprocess, time
if len(sys.argv) == 1:
    print("Spawning child")
    subprocess.Popen([sys.executable, sys.argv[0], "child"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print("Parent exiting")
else:
    time.sleep(1)
    with open("child_ran.txt", "w") as f:
        f.write("Child successfully ran")
