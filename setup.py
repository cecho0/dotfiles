#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import traceback
import yaml
import platform
import requests
import pwd
import os
import sys
import shutil
import tarfile
import zipfile
import subprocess
import time
from requests.exceptions import SSLError
from requests.exceptions import ProxyError
from requests.exceptions import ConnectTimeout
from requests.exceptions import ConnectionError
from pathlib import Path
from tqdm import tqdm

proxy = {
    "http": "",
    "https": "",
}

g_config = {}

# ANSI 转义码
reset = "\033[0m"      # reset
red = "\033[91m"       # red
green = "\033[92m"     # green
yellow = "\033[93m"    # yellow
bold = "\033[1m"       # bold
underline = "\033[4m"  # underline

def error_log(text):
    print(f"{red}{text}{reset}")

def success_log(text):
    print(f"{green}{text}{reset}")

def warn_log(text):
    print(f"{yellow}{text}{reset}")

def info_log(text):
    print(f"{bold}{text}{reset}")

def init_env():
    try:
        g_config["user"] = os.getlogin()
        g_config["arch"] = platform.machine()
        g_config["system"] = platform.system()
        g_config["tmp_path"] = os.path.dirname(os.path.realpath(__file__)) + "/.tmp_cache"
        g_config["tmp_bin_path"] = os.path.dirname(os.path.realpath(__file__)) + "/.tmp_cache/bin"
        g_config["tmp_software_path"] = os.path.dirname(os.path.realpath(__file__)) + "/.tmp_cache/software"

        if g_config["system"] != "Linux":
            error_log("this script only support linux now.")
            sys.exit()

        user = pwd.getpwnam(g_config["user"])
        g_config["home_path"] = user.pw_dir
        g_config["config_path"] = user.pw_dir + "/.config"
        g_config["root_path"] = os.path.dirname(os.path.realpath(__file__))
        g_config["install_type"] = "soft"

        success_log("arch: " + g_config["arch"])
        success_log("system: " + g_config["system"])
        success_log("home: " + g_config["home_path"])
        success_log("config: " + g_config["config_path"])
        success_log("root: " + g_config["root_path"])
        success_log("install type: " + g_config["install_type"])

    except FileNotFoundError as e:
        error_log("please use command 'sudo' to exec this script.")
        sys.exit()

    if os.path.exists(g_config["tmp_path"]):
        shutil.rmtree(g_config["tmp_path"])
    os.mkdir(g_config["tmp_path"])
    os.mkdir(g_config["tmp_bin_path"])
    os.mkdir(g_config["tmp_software_path"])

    if not os.path.exists(g_config["config_path"]):
        os.mkdir(g_config["config_path"])

def check_config_valid(data):
    if data["install_type"] != "soft" and data["install_type"] != "hard":
        error_log("option 'install_type' only support 'soft' or 'hard'")
        sys.exit()

    if not os.path.exists(g_config["home_path"]):
        error_log(f"home path format error")
        sys.exit()

def load_config():
    filename = os.path.dirname(os.path.realpath(__file__)) + "/config.yml"

    if g_config["arch"].lower() != "x86_64" or g_config["system"].lower() != "linux":
        error_log("only support x86_64 linux")
        sys.exit()

    # read data from yaml file
    if not os.path.exists(filename):
        error_log(f"config file: {filename} can't find")
        sys.exit()

    try:
        with open(filename, "r") as file:
            data = yaml.safe_load(file)
            check_config_valid(data)
            # set proxy
            if data["proxy"] != "":
                url = data["proxy"]
                proxy["http"] = f"http://{url}"
                proxy["https"] = f"http://{url}"
            g_config["install_type"] = data["install_type"]

            return data
    except yaml.parser.ParserError as e:
        error_log(f"yaml parser error: {e}")
        sys.exit()

def check_command(cmd):
    try:
        result = subprocess.run(["which", cmd], stdout  = subprocess.PIPE, stderr = subprocess.PIPE, text = True)
        if result.returncode == 0:
            return True
        return False
    except Exception as e:
        error_log(f"check command error: {e}")
        return False

def mod_uid_gid(dst, uid, gid):
    os.chown(dst, uid, gid)

    if os.path.isdir(dst):
        for root, dirs, files in os.walk(dst):
            for dir in dirs:
                os.chown(os.path.join(root, dir), uid, gid)
            for file in files:
                os.chown(os.path.join(root, file), uid, gid)

def get_file_size(url):
    file_response = None
    if proxy["http"] != "":
        file_response = requests.head(url, allow_redirects = True, proxies = proxy)
    else:
        file_response = requests.head(url, allow_redirects = True)

    if file_response.status_code != 200:
        error_log("get file content lenght failed.")
        return 0

    file_size = int(file_response.headers.get("content-length", 0))
    return file_size

def get_version_links(key, username, repo, token, link_format):
    api_url = f"https://api.github.com/repos/{username}/{repo}/releases/latest"
    headers = {"Authorization": token}

    try:
        if proxy["http"] != "":
            response = requests.get(api_url, headers = headers, proxies = proxy)
        else:
            response = requests.get(api_url, headers = headers)

        response = requests.get(api_url)
        if response.status_code != 200:
            warn_log(f"get {key} new version failed.")
            return None

        release_info = response.json()
        latest_version = release_info["tag_name"]

        # get all download links
        links = [asset["browser_download_url"] for asset in release_info["assets"]]
        if "version" in link_format:
            link_format = link_format.format(version = latest_version)

        # filter link
        for link in links:
            if link_format in link:
                return link

        error_log(f"{key} get download link failed.")
        return None
    except (SSLError, ProxyError, ConnectTimeout, ConnectionError )as e:
        error_log(f"SSL error: {e}")
        return None
    except OSError as e:
        error_log(f"OS error: {e}")
        return None
    except Exception as e:
        error_log(f"error: {e}")
        return None

def download_file(key, link):
    filename = os.path.basename(link)
    file_extension = os.path.splitext(filename)[1]

    try:
        file_size = get_file_size(link)
        if file_size == 0:
            return None

        progress_bar = tqdm(total = file_size, unit = 'B', unit_scale = True, desc = key)
        file_response = None
        if proxy["http"] != "":
            file_response = requests.get(link, stream = True, proxies = proxy)
        else:
            file_response = requests.get(link, stream = True)

        if file_response.status_code != 200:
            error_log("get file content failed.")
            return None

        local_file = g_config["tmp_path"] + "/package"
        if os.path.exists(local_file) and not os.path.isdir(local_file):
            os.remove(local_file)

        with open(g_config["tmp_path"] + "/package", "wb") as file:
            for data in file_response.iter_content(chunk_size = 1024):
                file.write(data)
                progress_bar.update(len(data))

        progress_bar.close()
        return (local_file, file_extension)

    except (SSLError, ProxyError, ConnectTimeout, ConnectionError )as e:
        return None
    except OSError as e:
        error_log(f"OS error: {e}")
        return None
    except Exception as e:
        error_log(f"error: {e}")
        return None

def handle_file(key, local_file, extension):
    if extension == ".gz":
        with tarfile.open(local_file, "r:gz") as tar:
            tar.extractall(g_config["tmp_software_path"])
    elif extension == ".zip":
        with zipfile.ZipFile(local_file, "r") as zip_ref:
            zip_ref.extractall(g_config["tmp_software_path"])
    else:
        error_log(f"unsupport format {extension}")
        return

    if key != "nvim":
        # copy file
        for root, dirs, files in os.walk(g_config["tmp_software_path"]):
            for file_name in files:
                if file_name == key:
                    target_file_path = os.path.join(root, file_name)
                    shutil.copy(target_file_path, g_config["tmp_bin_path"] + "/" + key)
    else:
        # neovim need copy whole directory
        for root, dirs, files in os.walk(g_config["tmp_software_path"]):
            for directory in dirs:
                if "nvim" in directory:
                    target_dir_path = os.path.join(root, directory)
                    shutil.move(target_dir_path, g_config["tmp_bin_path"] + "/" + key)

    # clean dir
    if os.path.exists(local_file):
        os.remove(local_file)
    if os.path.exists(g_config["tmp_software_path"]):
        shutil.rmtree(g_config["tmp_software_path"])
        os.mkdir(g_config["tmp_software_path"])

def download(data):
    if not data["download"]["enable"]:
        return

    for key in data["software"]:
        if check_command(key):
            info_log(f"{key} exist, skip...")
            continue

        username = data["software"][key]["username"]
        repo = data["software"][key]["repo"]
        token = data["github_token"]
        try_times = data["try_times"]
        link_format = data["software"][key]["link_format"]["linux"]

        try:
            # get version link
            times = try_times
            while times > 0:
                link = get_version_links(key, username, repo, token, link_format)
                if link != None:
                    break
                times = times - 1
                time.sleep(3)

            if link == None:
                continue

            # download file
            times = try_times
            local_file = None
            extension = None
            try:
                while times > 0:
                    (local_file, extension) = download_file(key, link)
                    if local_file != None:
                        break
                    times = times - 1
            except Exception as e:
                error_log(f"download {key} error: {e}, please retry wait a moment.")
                continue

            if local_file == None:
                continue

            handle_file(key, local_file, extension)

        except (SSLError, ProxyError, ConnectTimeout, ConnectionError )as e:
            error_log(f"request error: {e}")
            sys.exit()
        except OSError as e:
            error_log(f"OS error: {e}")
            sys.exit()
        except Exception as e:
            error_log(f"error: {e}")
            sys.exit()

    # start install software
    success_log("software download finished.")

def install(data):
    if not data["install"]["enable"]:
        return

    sp_list = {}
    for key in data["bin_path"]:
        if key != "common":
            sp_list[key] = data["bin_path"][key]
    bin_path = data["bin_path"]["common"]

    try:
        if not os.path.exists(bin_path):
            os.mkdir(bin_path)

        for filename in os.listdir(g_config["tmp_bin_path"]):
            if filename in sp_list:
                sp_path = sp_list[filename]["install"]
                if "home" in sp_path:
                    sp_path = sp_path.format(home = g_config["home_path"])
                elif "config" in sp_path:
                    sp_path = sp_path.format(home = g_config["config_path"])
                else:
                    error_log(f"{sp_path} path formatch error")
                    continue

                if not os.path.exists(sp_path):
                    os.mkdir(sp_path)
                ins_dst = sp_path + "/" + filename
                if os.path.exists(ins_dst) and os.path.isdir(ins_dst):
                    shutil.rmtree(ins_dst)

                shutil.move(g_config["tmp_bin_path"] + "/" + filename, ins_dst)
                user = pwd.getpwnam(g_config["user"])
                mod_uid_gid(ins_dst, user.pw_uid, user.pw_gid)

                link_src = sp_path + "/" + filename + "/" + sp_list[filename]["bin"]
                os.symlink(link_src, bin_path + "/" + filename)
                mod_uid_gid(link_src, user.pw_uid, user.pw_gid)

            else:
                shutil.move(g_config["tmp_bin_path"] + "/" + filename, bin_path + "/" + filename)
                mod_uid_gid(bin_path + "/" + filename, user.pw_uid, user.pw_gid)

    except OSError as e:
        error_log(f"OS error: {e}")
        sys.exit()
    except Exception as e:
        error_log(f"error: {e}")
        sys.exit()

    success_log("software install finished.")

def config_install(data):
    if not data["config"]["enable"]:
        return

    user = pwd.getpwnam(g_config["user"])
    for key in data["config"]:
        if key == "enable":
            continue

        if not data["config"][key]["enable"]:
            continue

        config_format = data["config"][key]["config_path"]
        root_format = data["config"][key]["root_path"]
        config_path = None
        if "home_path" in config_format:
            config_path = config_format.format(home_path = g_config["home_path"])
        elif "config_path" in config_format:
            config_path = config_format.format(config_path = g_config["config_path"])
        else:
            error_log("error format {}", config_format)
            continue

        root_path = root_format.format(root_path = g_config["root_path"])
        try:
            if g_config["install_type"] == "soft":
                os.symlink(root_path, config_path)
                os.lchown(config_path, user.pw_uid, user.pw_gid)
            if g_config["install_type"] == "hard":
                shutil.copy(root_path, config_path)
                mod_uid_gid(config_path, user.pw_uid, user.pw_gid)
        except OSError as e:
            error_log(f"create soft link failed, error: {e}")
    success_log("configure install finished.")

def clean(data):
    # delete tmp directory
    if os.path.exists(g_config["tmp_path"]):
        shutil.rmtree(g_config["tmp_path"])

def main():
    init_env()
    data = load_config()

    download(data)
    install(data)
    config_install(data)
    clean(data)

if __name__== "__main__" :
    main()
