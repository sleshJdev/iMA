def launch_workbench_in_server_mode(host, port, showgui, ansys_project, workbench_exe_name):
    import os, subprocess, time
    awpVal = os.environ.get("AWP_ROOT182")
    framework_path = os.path.join(awpVal, os.path.join("Framework", os.path.join("bin", "Win64")))
    workbench_exe_path = os.path.join(framework_path, workbench_exe_name)
    args = [workbench_exe_path, "-P", str(port), "-H", host, "-F", ansys_project]
            
    if showgui != True:
        args.append("-nowindow")
        args.append("-B")
    subprocess.Popen(args)
    time.sleep(45.0)

if __name__ == "__main__": 
    import sys, argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-DE', type=str, default='RunWB2.exe')
    parser.add_argument('-H', type=str, default='localhost')
    parser.add_argument('-P', type=int, default=8001)
    parser.add_argument('-F', type=str)
    parser.add_argument('-showgui', type=bool, default=True)
    args = parser.parse_args()
    launch_workbench_in_server_mode(args.H, args.P, args.showgui, args.F, args.DE)