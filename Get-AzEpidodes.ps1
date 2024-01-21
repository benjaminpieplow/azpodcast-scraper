# Rips all episodes of the Azure Podcast https://azpodcast.azurewebsites.net/
# Author: Benjamin Rohner
# Date: 2024-01-20
# More of a learning project...

# Scrape Range
$StartEpisode = 1
$EndEpisode = 9001 # Script will stop if 

# This probably won't change.
$EpisodeBase = "https://azpodcast.blob.core.windows.net/episodes/"
$LocalPath = "./Output/"

# Discover the latest episode using brute-force (attempt). Feeling bored? Make this faster by scaling guesses logarithmically until a miss.
function Get-LastEpisode {
    param ()
    # Set counter to first episode
    $TestEpisodeNumber = $StartEpisode
    # PowerShell Scoping Sucks
    $Stop = 0
    do {
        try {
            $TestEpisodeUri = $EpisodeBase + "Episode" + "$TestEpisodeNumber" + ".mp3"
            Invoke-WebRequest -Uri $TestEpisodeUri -Method Head
            $TestEpisodeNumber = $TestEpisodeNumber + 1
        }
        catch {
            if ($_.Exception.StatusCode -eq "NotFound") {
                Write-Host "Last episode is $TestEpisodeNumber"
                $Stop = 1
            }
        }
    } until (
        $TestEpisodeNumber -gt $EndEpisode -or $Stop -eq 1
    )
    # Maybe there's a smarter way to do this, maybe it doesn't matter
    return ($TestEpisodeNumber - 1)
}

# Download a specific episode
function Download-Episode {
    param (
        [Parameter(Mandatory=$true)]
        [int]$EpisodeNumber
    )
    $DownloadUri = $EpisodeBase + "Episode" + "$EpisodeNumber" + ".mp3"
    $Destination = $LocalPath + "Episode" + "$EpisodeNumber" + ".mp3"
    Invoke-WebRequest -Uri $DownloadUri -OutFile $Destination
}

#Get-LastEpisode
Download-Episode -EpisodeNumber 100