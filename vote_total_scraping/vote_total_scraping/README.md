This project required data collection for a political science professor. We collected presidential election data for every state from 2000 to 2020. The data was collected from official house clerk election statistics. To accomplish this I wrote 1) a python program that downloaded all presidential election data pdf's stored on the website, 2) a program that scraped data from the pdf's after identifying relevant pages on the pdf's, and then stored the data in an excel sheet for the professor to use. 

The download_datafiles.py file downloaded the pdf files from the website and stores them on a local folder. 




```python
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

```

The main_3.py file opens every file and selects pages based on whether a line of text is found that precedes the presidential election information. The program stories the State, party, number of votes, and year for every election year pdf. The program then outputs the file into an excel file. 


```python
import os
import re
import glob
import pdfplumber
from openpyxl import Workbook

def extract_presidential_elector_data(pdf_path):
    """
    Extracts the 'For Presidential Electors' section data from a PDF.
    Returns a list of tuples (state, party, votes).
    """
    data = []  # holds tuples of (state, party, votes)
    # Regex to capture a party name and numeric votes, e.g. "Republican ... 273,559"
    party_votes_pattern = re.compile(r'^(.*?)\s+(\d[\d,]*)$')

    # Regex for headings: e.g. "ARKANSAS", "ARKANSAS—Continued", "CALIFORNIA - CONTINUED"
    state_heading_pattern = re.compile(
        r'^([A-Z ]+)(?:[—-]\s*CONTINUED)?$',
        re.IGNORECASE
    )

    with pdfplumber.open(pdf_path) as pdf:
        current_state = None
        capturing = False

        for page in pdf.pages:
            text = page.extract_text()
            if not text:
                continue

            lines = text.split('\n')
            for line in lines:
                print("DEBUG repr(line):", repr(line))

                # Strip possible weird chars and work in uppercase
                line_stripped = line.strip().upper()
                line_stripped = re.sub(r'[\u00A0\x0c]+', '', line_stripped)

                # 1) First, check if this is the "FOR PRESIDENTIAL ELECTORS" line.
                #    This must be checked before the state-heading regex.
                if 'FOR PRESIDENTIAL ELECTORS' in line_stripped:
                    capturing = True
                    continue

                # 2) If we are capturing and the line starts with "FOR ", stop capturing.
                if capturing and line_stripped.startswith('FOR '):
                    capturing = False
                    continue

                # 3) Next, check for a state heading.
                #    This block is reached only if the line wasn't caught by the above.
                match_state = state_heading_pattern.match(line_stripped)
                if match_state:
                    new_state = match_state.group(1).strip()
                    current_state = new_state
                    capturing = False  # reset capturing for new state
                    continue

                # 4) When capturing, match party/vote lines.
                if capturing:
                    match = party_votes_pattern.match(line.strip())
                    if match:
                        party_str = match.group(1).strip()
                        votes_str = match.group(2).replace(',', '')
                        try:
                            votes = int(votes_str)
                        except ValueError:
                            votes = 0
                        data.append((current_state, party_str, votes))

    return data


def extract_year_from_filename(pdf_path):
    """
    Extracts the first 4-digit year (e.g., 2000, 2004, 2008) found in the PDF filename.
    Returns the year as a string, or None if not found.
    """
    basename = os.path.basename(pdf_path)
    match = re.search(r'(19|20)\d{2}', basename)
    return match.group(0) if match else None


def save_data_to_excel(data, output_xlsx):
    """
    Saves a list of (state, party, votes, year) tuples to an Excel file.
    """
    wb = Workbook()
    ws = wb.active
    ws.title = "Presidential Electors"

    # Write header row with Year included
    ws.append(["State", "Party", "Votes", "Year"])

    # Write data rows
    for row in data:
        ws.append(row)

    wb.save(output_xlsx)


def main():
    # Folder where PDF files are stored
    pdf_folder = "pdfs"
    # Use glob to find all PDF files in the folder
    pdf_files = glob.glob(os.path.join(pdf_folder, "*.pdf"))

    if not pdf_files:
        print(f"No PDF files found in folder: {pdf_folder}")
        return

    all_data = []  # To store data from all PDFs

    for pdf_file in pdf_files:
        print(f"Processing {pdf_file}...")
        year = extract_year_from_filename(pdf_file)
        if not year:
            print(f"Year not found in filename: {pdf_file}. Skipping.")
            continue

        # Extract the election data from the current PDF
        elector_data = extract_presidential_elector_data(pdf_file)
        # Append the extracted year to each record
        for record in elector_data:
            state, party, votes = record
            all_data.append((state, party, votes, year))

    # Save the combined data to an Excel file
    output_excel = "output_3.xlsx"
    save_data_to_excel(all_data, output_excel)
    print("Extraction complete. Data saved to", output_excel)


if __name__ == "__main__":
    main()

```

The clean_data_2.py file cleans the data and outputs it to a separate file. 
