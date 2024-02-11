#!/usr/bin/env python3
# -*- coding: utf-8 -*-

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
from tqdm import tqdm

# ANSI 转义码
reset = "\033[0m"      # reset
red = "\033[91m"       # red
green = "\033[92m"     # green
yellow = "\033[93m"    # yellow
bold = "\033[1m"       # bold
underline = "\033[4m"  # underline

class Log:
    @staticmethod
    def info(text: str):
        print(f"{green}{text}{reset}")

    @staticmethod
    def warning(text: str):
        print(f"{yellow}{text}{reset}")

    @staticmethod
    def error(text: str):
        print(f"{red}{text}{reset}")

class Config:
    def __init__(self, proxy_url: str = ""):
        # user
        self.__user = os.getlogin()
        self.__home_dir = pwd.getpwnam(self.__user).pw_dir
        self.__config_dir = pwd.getpwnam(self.__user).pw_dir + "/.config"

        # arch and system
        self.__arch = platform.machine()
        self.__system = platform.system()

        # proxy
        if proxy_url == "":
            self.__proxy_enable = False
        else:
            self.__proxy_enable = True
        self.__proxy_url = proxy_url
        self.__proxy_format = {}
        self.__proxy_format["http"] = ""
        self.__proxy_format["https"] = ""

        # cache
        self.__cache_path = os.path.dirname(os.path.realpath(__file__)) + "/.tmp_cache"
        self.__cache_bin_path = self.__cache_path + "/bin"
        self.__cache_software_path = self.__cache_path + "/software"

        # other
        self.__root_dir = os.path.dirname(os.path.abspath(__file__))
        self.__install_type = "soft"

    def getUser(self) -> str:
        return self.__user

    def setUser(self, user: str):
        self.__user = user

    def getArch(self) -> str:
        return self.__arch

    def getSystem(self) -> str:
        return self.__system

    def getHomeDir(self) -> str:
        return self.__home_dir

    def getConfigDir(self) -> str:
        return self.__config_dir

    def needProxy(self) -> bool:
        return self.__proxy_enable

    def getProxy(self) -> dict:
        if self.__proxy_enable:
            return self.__proxy_format
        else:
            return None

    def setProxy(self, url: str):
        if url != "":
            self.__proxy_enable = True
        else:
            self.__proxy_enable = False
        self.__proxy_url = url
        self.__proxy_format["http"] = f"http://{self.__proxy_url}"
        self.__proxy_format["https"] = f"http://{self.__proxy_url}"

    def getCachePath(self) -> str:
        return self.__cache_path

    def getCacheBinPath(self) -> str:
        return self.__cache_bin_path

    def getCacheSoftwarePath(self) -> str:
        return self.__cache_software_path

    def getRootPath(self) -> str:
        return self.__root_dir

    def getInstallType(self) -> str:
        return self.__install_type

    def setInstallType(self, type: str) -> bool:
        if type != "soft" and type != "hard":
            return False

        self.__install_type = type
        return True

    def display(self):
        Log.info("User: " + self.getUser())
        Log.info("Arch: " + self.getArch())
        Log.info("System: " + self.getSystem())
        Log.info("Install: " + self.getInstallType())

def checkInput(message: str) -> bool:
    ans = input(f"\n{message}, Y or N ? (default Y): ")
    if ans == '' or ans == 'y' or ans == 'Y':
        return True
    return False

def checkEnv(conf: Config) -> bool:
    if conf.getSystem() != "Linux" or conf.getArch() != "x86_64":
        Log.error("this script only support 64bit linux now.");
        return False

    try:
        if os.path.exists(conf.getCachePath()):
            shutil.rmtree(conf.getCachePath())
        os.mkdir(conf.getCachePath())
        os.mkdir(conf.getCacheBinPath())
        os.mkdir(conf.getCacheSoftwarePath())
        user = pwd.getpwnam(conf.getUser())
        modUidGid(conf.getCachePath(), user.pw_uid, user.pw_gid)

        if not os.path.exists(conf.getConfigDir()):
            os.mkdir(conf.getConfigDir())
            user = pwd.getpwnam(conf.getUser())
            modUidGid(conf.getCachePath(), user.pw_uid, user.pw_gid)
    except OSError as e:
        Log.error(f"OS Error: {e}")
        return False

    return True

def initEnv():
    try:
        conf = Config()
        conf.display()

        return conf
    except FileNotFoundError:
        Log.error("please use command 'sudo' to exec this script.")
        sys.exit()

def loadYamlFile(conf: Config) -> (bool, dict):
    file = os.path.dirname(os.path.realpath(__file__)) + "/config.yml"
    if not os.path.exists(file):
        Log.error(f"can't find configure file: {0}", file)
        return False, None

    # read data from yaml file
    try:
        with open(file, "r") as file_r:
            data = yaml.safe_load(file_r)

            # set proxy
            if data["proxy"]["enable"]:
                conf.setProxy(data["proxy"]["url"])
            # set install type
            if data["install_type"]:
                conf.setInstallType(data["install_type"])

            return True, data
    except yaml.parser.ParserError as e:
        Log.error(f"yaml parser error: {e}")
        return False, None

def cleanEnv(conf: Config):
    # delete cache directory
    try:
        if os.path.exists(conf.getCachePath()):
            shutil.rmtree(conf.getCachePath())
        sys.exit()
    except OSError as e:
        Log.error(f"OS Error: {e}")
        sys.exit()

def checkCommand(cmd: str) -> bool:
    try:
        result = subprocess.run(["which", cmd], stdout  = subprocess.PIPE, stderr = subprocess.PIPE, text = True)
        if result.returncode == 0:
            return True
        return False
    except Exception as e:
        Log.error(f"check command error: {e}")
        return False

def modUidGid(dst: str, uid: int, gid: int):
    os.chown(dst, uid, gid)

    if os.path.isdir(dst):
        for root, dirs, files in os.walk(dst):
            for dir in dirs:
                os.chown(os.path.join(root, dir), uid, gid)
            for file in files:
                os.chown(os.path.join(root, file), uid, gid)

def getVersionLinks(conf: Config, key: str, username: str, repo: str, token: str, link_format: str) -> str:
    api_url = f"https://api.github.com/repos/{username}/{repo}/releases/latest"
    headers = {"Authorization": token}

    try:
        response = requests.get(api_url, headers = headers, proxies = conf.getProxy())
        if response.status_code != 200:
            Log.warning(f"get {key} new version failed.")
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

        Log.error(f"{key} get download link failed.")
        return None
    except (SSLError, ProxyError, ConnectTimeout, ConnectionError )as e:
        Log.error(f"SSL Error: {e}")
        return None
    except OSError as e:
        Log.error(f"OS Error: {e}")
        return None
    except Exception as e:
        Log.error(f"STD Error: {e}")
        return None

def getFileSize(conf: Config, url: str) -> int:
    response = requests.head(url, allow_redirects = True, proxies = conf.getProxy())
    if response.status_code != 200:
        Log.error("get file content length failed.")
        return 0

    return int(response.headers.get("content-length", 0))

def downloadFile(conf: Config, key: str, link: str) -> tuple:
    filename = os.path.basename(link)
    file_extension = os.path.splitext(filename)[1]

    try:
        file_size = getFileSize(conf, link)
        if file_size == 0:
            return None

        progress_bar = tqdm(total = file_size, unit = 'B', unit_scale = True, desc = key)
        file_response = requests.get(link, stream = True, proxies = conf.getProxy())

        if file_response.status_code != 200:
            Log.error("get file content failed.")
            return None

        local_file = conf.getCacheSoftwarePath() + "/package"
        if os.path.exists(local_file) and not os.path.isdir(local_file):
            os.remove(local_file)

        with open(local_file, "wb") as file:
            for data in file_response.iter_content(chunk_size = 1024):
                file.write(data)
                progress_bar.update(len(data))

        progress_bar.close()
        return (local_file, file_extension)

    except (SSLError, ProxyError, ConnectTimeout, ConnectionError ) as e:
        Log.error(f"Request Error: {e}")
    except OSError as e:
        Log.error(f"OS Error: {e}")
    except Exception as e:
        Log.error(f"STD Error: {e}")
    return (None, None)

def handleFile(conf: Config, key: str, local_file: str, extension: str, single: bool):
    if extension == ".gz":
        with tarfile.open(local_file, "r:gz") as tar:
            tar.extractall(conf.getCacheSoftwarePath())
    elif extension == ".zip":
        with zipfile.ZipFile(local_file, "r") as zip_ref:
            zip_ref.extractall(conf.getCacheSoftwarePath())
    else:
        Log.error(f"unsupport format {extension}")
        return

    if single:
        # copy file
        for root, dirs, files in os.walk(conf.getCacheSoftwarePath()):
            for file_name in files:
                if file_name == key:
                    target_file_path = os.path.join(root, file_name)
                    shutil.copy(target_file_path, conf.getCacheBinPath() + "/" + key)
    else:
        # need copy whole directory
        for root, dirs, files in os.walk(conf.getCacheSoftwarePath()):
            for directory in dirs:
                if key in directory:
                    target_dir_path = os.path.join(root, directory)
                    shutil.move(target_dir_path, conf.getCacheBinPath() + "/" + key)

    # clean file
    if os.path.exists(local_file):
        os.remove(local_file)
    if os.path.exists(conf.getCacheSoftwarePath()):
        shutil.rmtree(conf.getCacheSoftwarePath())
        os.mkdir(conf.getCacheSoftwarePath())
        user = pwd.getpwnam(conf.getUser())
        modUidGid(conf.getCacheSoftwarePath(), user.pw_uid, user.pw_gid)

def downloadSoftware(conf: Config, data: dict) -> bool:
    if not data["download"]["enable"]:
        return

    ans = checkInput("Start Download")
    if not ans:
        Log.info("Stop Setup Script.")
        return False
    else:
        Log.warning("\nDownloading...")

    for key in data["software"]:
        if checkCommand(key):
            Log.info(f"{key} exist, skip...")
            continue

        username = data["software"][key]["username"]
        repo = data["software"][key]["repo"]
        token = data["github_token"]
        try_times = data["try_times"]
        link_format = data["software"][key]["link_format"][conf.getSystem().lower()]

        # get version link
        times = try_times
        while times > 0:
            link = getVersionLinks(conf, key, username, repo, token, link_format)
            if link != None:
                break

            times = times - 1
            time.sleep(10)

        if link == None:
            Log.warning(f"get {key} version link over 3 times, skip...")
            continue

        # download file
        times = try_times
        local_file = None
        extension = None

        while times > 0:
            (local_file, extension) = downloadFile(conf, key, link)
            if local_file != None:
                break
            times = times - 1
            time.sleep(10)

        if local_file == None:
            Log.warning(f"download {key} over 3 times, skip...")
            continue

        # move bin file
        handleFile(conf, key, local_file, extension, data["software"][key]["single"])
    Log.warning("download finish.")

def installSoftware(conf: Config, data: dict) -> bool:
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

        for filename in os.listdir(conf.getCacheBinPath()):
            if filename in sp_list:
                # special software
                sp_path = sp_list[filename]["install"]
                if "home" in sp_path:
                    sp_path = sp_path.format(home = conf.getHomeDir())
                elif "config" in sp_path:
                    sp_path = sp_path.format(config = conf.getConfigDir())
                else:
                    Log.error(f"{sp_path} path formatch error")
                    continue

                # install position
                if not os.path.exists(sp_path):
                    os.mkdir(sp_path)
                    user = pwd.getpwnam(conf.getUser())
                    modUidGid(sp_path, user.pw_uid, user.pw_gid)
                dst = sp_path + "/" + filename
                src = conf.getCacheBinPath() + "/" + filename
                if os.path.exists(dst) and os.path.isdir(dst):
                    shutil.rmtree(dst)

                shutil.move(src, dst)
                user = pwd.getpwnam(conf.getUser())
                modUidGid(dst, user.pw_uid, user.pw_gid)

                link_src = sp_path + "/" + filename + "/" + sp_list[filename]["bin"]
                link_dst = bin_path + "/" + filename
                os.symlink(link_src, link_dst)
                modUidGid(link_dst, user.pw_uid, user.pw_gid)
            else:
                src = conf.getCacheBinPath() + "/" + filename
                dst = bin_path + "/" + filename
                shutil.move(src, dst)
                user = pwd.getpwnam(conf.getUser())
                modUidGid(dst, user.pw_uid, user.pw_gid)

        Log.warning("software install finished.")
        return True
    except OSError as e:
        Log.error(f"OS Error: {e}")
    except Exception as e:
        Log.error(f"STD Error: {e}")
    return False

def installConfig(conf: Config, data: dict):
    if not data["config"]["enable"]:
        return

    user = pwd.getpwnam(conf.getUser())
    for key in data["config"]:
        if key == "enable":
            continue

        if not data["config"][key]["enable"]:
            continue

        config_format = data["config"][key]["config_path"]
        root_format = data["config"][key]["root_path"]
        config_path = None
        if "home_path" in config_format:
            config_path = config_format.format(home_path = conf.getHomeDir())
        elif "config_path" in config_format:
            config_path = config_format.format(config_path = conf.getConfigDir())
        else:
            Log.error("error format {}", config_format)
            continue

        root_path = None
        if "root_path" in root_format:
            root_path = root_format.format(root_path = conf.getRootPath())
        else:
            Log.error("error format {}", root_format)
            continue

        try:
            if conf.getInstallType() == "soft":
                if not os.path.exists(root_path):
                    Log.error(f"{root_path} not exist. skip...")
                    continue
                if os.path.exists(config_path):
                    Log.error(f"{config_path} already exist. skip...");
                    continue
                os.symlink(root_path, config_path)
                os.lchown(config_path, user.pw_uid, user.pw_gid)
                modUidGid(config_path, user.pw_uid, user.pw_gid)
            if conf.getInstallType() == "hard":
                if not os.path.exists(root_path):
                    Log.error(f"{root_path} not exist. skip...")
                    continue
                if os.path.exists(config_path):
                    Log.error(f"{config_path} already exist. skip...");
                    continue

                if os.path.isdir(root_path):
                    shutil.copytree(root_path, config_path)
                else:
                    shutil.copy(root_path, config_path)

                modUidGid(config_path, user.pw_uid, user.pw_gid)
        except OSError as e:
            Log.error(f"create soft link failed, error: {e}")
    Log.warning("configure install finished.")

def main():
    conf = initEnv()
    if checkEnv(conf) == False:
        cleanEnv(conf)

    res, data = loadYamlFile(conf)
    if res == False:
        cleanEnv(conf)

    downloadSoftware(conf, data)
    installSoftware(conf, data)
    installConfig(conf, data)
    cleanEnv(conf)

if __name__== "__main__" :
    main()

