# Ask the user for the destination folder for the addons
$targetInput = Read-Host "Please enter the path to the folder where you want to install the addons"

# If the user provides a relative path, resolve it relative to the script's directory
if (-not [System.IO.Path]::IsPathRooted($targetInput)) {
    $targetDir = Join-Path -Path $PSScriptRoot -ChildPath $targetInput
} else {
    $targetDir = $targetInput
}

# Create the target directory if it doesn't exist
if (-not (Test-Path $targetDir)) {
    Write-Host "Creating directory $targetDir..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
}

# Path to the JSON file containing the repositories (assumed to be in the same folder as the script)
$jsonPath = Join-Path -Path $PSScriptRoot -ChildPath "repos.json"

if (-not (Test-Path $jsonPath)) {
    Write-Host "Error: Could not find $jsonPath" -ForegroundColor Red
    Write-Host "Please create a repos.json file with {`"Name`": `"owner/repo`"} format." -ForegroundColor Yellow
    exit
}

# Read and parse the JSON file
$jsonContent = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json

# Extract the links (values)
$repos = $jsonContent.psobject.properties.Value

Write-Host "Starting downloads to: $targetDir" -ForegroundColor Cyan

foreach ($link in $repos) {
    # Extract owner/repo using regex to handle different link formats safely
    if ($link -match "github\.com/([^/]+)/([^/]+)") {
        $repo = "$($matches[1])/$($matches[2])"
    } elseif ($link -match "^([^/]+)/([^/]+)$") {
        $repo = $link
    } else {
        Write-Host "`nSkipping $link - Invalid format. Expected 'owner/repo' or full GitHub URL." -ForegroundColor Yellow
        continue
    }
    
    # Clean up potential '.git' at the end
    $repo = $repo -replace "\.git$", ""
    
    Write-Host "`nFetching latest release for $repo..." -ForegroundColor Green
    $apiUrl = "https://api.github.com/repos/$repo/releases/latest"
    
    try {
        # Fetch the release information from GitHub API
        $release = Invoke-RestMethod -Uri $apiUrl -ErrorAction Stop
        
        # Look for a .zip asset
        $asset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1
        
        if ($asset) {
            $downloadUrl = $asset.browser_download_url
            $fileName = $asset.name
            $destination = Join-Path -Path $targetDir -ChildPath $fileName
            
            Write-Host "Downloading $($asset.name)..."
            Invoke-WebRequest -Uri $downloadUrl -OutFile $destination
            
            Write-Host "Extracting $fileName..."
            Expand-Archive -Path $destination -DestinationPath $targetDir -Force
            
            # Remove the zip file after extracting to keep things clean
            Remove-Item -Path $destination -Force
            
            Write-Host "Successfully downloaded and installed $repo." -ForegroundColor DarkGreen
        } else {
            Write-Host "No .zip asset found for $repo." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Failed to process $repo. Error: $_" -ForegroundColor Red
    }
}

Write-Host "`nAll done!" -ForegroundColor Cyan
