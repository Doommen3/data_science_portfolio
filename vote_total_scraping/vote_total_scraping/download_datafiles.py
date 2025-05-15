import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin


def download_pdf(pdf_url, filename):
    """
    Downloads a PDF from the given URL and saves it locally.
    """
    try:
        print(f"Downloading: {pdf_url}")
        response = requests.get(pdf_url)
        response.raise_for_status()
        with open(filename, 'wb') as file:
            file.write(response.content)
        print(f"Saved as: {filename}")
    except Exception as e:
        print(f"Error downloading {pdf_url}: {e}")


def main():
    # Base page containing the election statistics links
    base_page = "https://history.house.gov/Institution/Election-Statistics/Election-Statistics/"
    # Define the target presidential election years
    target_years = ["2000", "2004", "2008"]

    try:
        response = requests.get(base_page)
        response.raise_for_status()
    except Exception as e:
        print(f"Error fetching the base page: {e}")
        return

    soup = BeautifulSoup(response.content, "html.parser")

    # Create a directory to store downloaded PDFs
    download_dir = "pdfs"
    os.makedirs(download_dir, exist_ok=True)

    # Find all anchor tags whose href attribute contains ".pdf"
    pdf_links = soup.find_all("a", href=lambda href: href and ".pdf" in href.lower())

    if not pdf_links:
        print("No PDF links found on the page!")
        return

    for link in pdf_links:
        link_text = link.get_text().strip()
        href = link.get("href")
        # Check if either the link text or URL contains one of the target years.
        # Also ensure that the link text mentions "president" or "presidential".
        if (any(year in link_text or year in href for year in target_years) and
                ("president" in link_text.lower() or "presidential" in link_text.lower())):
            pdf_url = urljoin(base_page, href)
            filename = os.path.join(download_dir, os.path.basename(pdf_url))
            download_pdf(pdf_url, filename)
        else:
            # If needed, uncomment the following line to see which links were skipped.
            # print(f"Skipping link (not matching criteria): {link_text} -> {href}")
            pass


if __name__ == "__main__":
    main()
