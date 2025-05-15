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
