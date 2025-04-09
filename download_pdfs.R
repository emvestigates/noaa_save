library(RSelenium)
library(dplyr)

# Read noaa_urls.csv from the repository
metadata <- read.csv("noaa_urls.csv")  # Ensure the file is located in the current working directory
urls <- metadata$dc.identifier

# Set download path to the mapped directory in the container
output_dir <- "/home/selenium/pdfs"  # This will map to ${{ github.workspace }}/pdfs

# Chrome options to specify the download directory
chrome_options <- list(
  "prefs" = list(
    "download.default_directory" = output_dir,  # Specify download directory inside container
    "download.prompt_for_download" = FALSE,  # Disable download prompt
    "download.directory_upgrade" = TRUE,  # Allow directory upgrade
    "safebrowsing.enabled" = TRUE  # Enable safe browsing for the download
  )
)

# Initialize RSelenium with the specified Chrome options
driver <- rsDriver(browser = "chrome", port = as.integer(4444), chromever = "latest", extraCapabilities = chrome_options)
remote_driver <- driver[["client"]]

# Function to click the button and download the PDF
click_download_button <- function(url, output_dir) {
  # Navigate to the URL
  remote_driver$navigate(url)
  
  # Wait for the button to be present
  remote_driver$waitForElementPresent("button#download-document-submit", timeout = 10)
  
  # Click the button to download
  button <- remote_driver$findElement(using = "css selector", "button#download-document-submit")
  button$click()
  
  # Wait for download to complete
  Sys.sleep(5)  # Wait for download to finish
  
  # Check if the download exists in the specified folder
  downloaded_pdf <- Sys.glob(file.path(output_dir, "*.pdf"))  # Search for PDF files
  if (length(downloaded_pdf) > 0) {
    print(paste("Downloaded:", downloaded_pdf[1]))  # Print the downloaded PDF file path
  } else {
    print("No PDF downloaded")
  }
}

# Iterate over the URLs and download the PDFs
for (url in urls) {
  click_download_button(url, output_dir)
}

# Stop the RSelenium session after use
remote_driver$close()
driver[["server"]]$stop()
