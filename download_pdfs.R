library(RSelenium)
library(dplyr)

# Read noaa_urls.csv from the repository (this should now be available in the local working directory)
metadata <- read.csv("noaa_urls.csv")  # Ensure the file is located in the current working directory
urls <- metadata$dc.identifier

# Initialize RSelenium (Start the browser)
driver <- rsDriver(browser = "chrome", port = 4444, chromever = "latest")
remote_driver <- driver[["client"]]

# Function to click the button and download the PDF
click_download_button <- function(url, output_dir) {
  # Navigate to the URL
  remote_driver$navigate(url)
  
  # Wait for the button to be present (you may need to adjust the timeout or add additional waits)
  remote_driver$waitForElementPresent("button#download-document-submit", timeout = 5)
  
  # Click the button to download
  button <- remote_driver$findElement(using = "css selector", "button#download-document-submit")
  button$click()
  
  # Wait for download to complete (adjust if necessary)
  Sys.sleep(3)
  
  # Move the downloaded PDF to the output directory
  # Assuming the download path is set in the browser settings (default location)
  downloaded_pdf <- Sys.glob("~/Downloads/*.pdf")  # Adjust path if needed
  if (length(downloaded_pdf) > 0) {
    file.rename(downloaded_pdf[1], file.path(output_dir, basename(downloaded_pdf[1])))
  }
}

# Create the output directory for PDFs
output_dir <- "pdfs"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Iterate over the URLs and download the PDFs
for (url in urls) {
  click_download_button(url, output_dir)
}

# Stop the RSelenium session after use
remote_driver$close()
driver[["server"]]$stop()
