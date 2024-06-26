#!/usr/bin/python3
"""A module for web application deployment with Fabric."""
import os
from datetime import datetime
from fabric.api import env, local, put, run, runs_once

# Define the list of host server IP addresses
env.hosts = ["34.73.0.174", "35.196.78.105"]

@runs_once
def do_pack():
    """Archives the static files into a .tgz archive."""
    if not os.path.isdir("versions"):
        os.mkdir("versions")
    
    cur_time = datetime.now()
    output = "versions/web_static_{}{}{}{}{}{}.tgz".format(
        cur_time.year, cur_time.month, cur_time.day,
        cur_time.hour, cur_time.minute, cur_time.second
    )
    
    try:
        print("Packing web_static to {}".format(output))
        local("tar -cvzf {} web_static".format(output))
        archive_size = os.stat(output).st_size
        print("web_static packed: {} -> {} Bytes".format(output, archive_size))
    except Exception as e:
        print("An error occurred while packing: {}".format(e))
        output = None
    
    return output

def do_deploy(archive_path):
    """Deploys the static files to the host servers.
    
    Args:
        archive_path (str): The path to the archived static files.
    """
    if not os.path.exists(archive_path):
        return False
    
    file_name = os.path.basename(archive_path)
    folder_name = file_name.replace(".tgz", "")
    folder_path = "/data/web_static/releases/{}/".format(folder_name)
    
    try:
        put(archive_path, "/tmp/{}".format(file_name))
        run("mkdir -p {}".format(folder_path))
        run("tar -xzf /tmp/{} -C {}".format(file_name, folder_path))
        run("rm -rf /tmp/{}".format(file_name))
        run("mv {}/web_static/* {}".format(folder_path, folder_path))
        run("rm -rf {}/web_static".format(folder_path))
        run("rm -rf /data/web_static/current")
        run("ln -s {} /data/web_static/current".format(folder_path))
        print('New version deployed!')
        return True
    except Exception as e:
        print("An error occurred while deploying: {}".format(e))
        return False

def deploy():
    """Archives and deploys the static files to the host servers."""
    archive_path = do_pack()
    return do_deploy(archive_path) if archive_path else False

