# CS2 Plugin Downloader

This repository contains a PowerShell script designed to automate the process of downloading and extracting the latest releases of various GitHub repositories, specifically tailored for managing CS2 plugins or addons.

## Overview

The `DownloadRepos.ps1` script reads a list of GitHub repository URLs from a `repos.json` file. It then prompts the user for a destination folder, connects to the GitHub API to find the latest release for each repository, downloads the associated `.zip` asset, and extracts it directly into the specified directory. 

## Usage

1. **Configure Repositories**: Create a `repos.json` file in the same directory as the script. It should contain a JSON object where values are the GitHub repository links (or `owner/repo` format).

    ```json
    {
        "Plugin1": "owner1/repo1",
        "Plugin2": "https://github.com/owner2/repo2"
    }
    ```

2. **Run the Script**: Execute the `DownloadRepos.ps1` script in PowerShell.

    ```powershell
    .\DownloadRepos.ps1
    ```

3. **Specify Destination**: When prompted, enter the path to the folder where you want the addons installed. The script will handle the downloading, extraction, and cleanup of the zip files.

## Requirements

- Windows PowerShell or PowerShell Core.
- Internet access to reach `api.github.com`.
