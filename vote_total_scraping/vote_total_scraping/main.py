import pdfplumber
import re
from openpyxl import Workbook

def extract_presidential_elector_data(pdf_path):
    """
    Extracts the 'For Presidential Electors' section data from each state
    and returns a list of (state, party, votes).
    """
    data = []  # will hold tuples of (state, party, votes)

    # Simple regex that attempts to capture a party name and numeric votes
    # e.g. "Republican .................................. 273,559"
    # You may have to adjust this pattern depending on the PDF text format.
    party_votes_pattern = re.compile(r'^(.*?)\s+(\d[\d,]*)$')

    with pdfplumber.open(pdf_path) as pdf:
        current_state = None
        capturing = False

        for page in pdf.pages:
            lines = page.extract_text().split('\n')
            for line in lines:
                # Check if line is a new state heading (like "NEW HAMPSHIRE" in all caps).
                # You might refine this if your PDF has more precise heading formatting.
                if re.match(r'^[A-Z ]+$', line.strip()) and 'FOR' not in line:
                    current_state = line.strip()
                    capturing = False  # we haven't yet seen "FOR PRESIDENTIAL ELECTORS"

                # Check if we've hit the "FOR PRESIDENTIAL ELECTORS" line
                elif 'FOR PRESIDENTIAL ELECTORS' in line.upper():
                    capturing = True
                    continue

                # If we detect the next heading, stop capturing for this state
                elif capturing and line.strip().upper().startswith('FOR '):
                    # e.g. "FOR UNITED STATES REPRESENTATIVE"
                    capturing = False
                    continue

                # If we’re in capturing mode, try to parse party/vote lines
                elif capturing:
                    # Attempt a regex match
                    match = party_votes_pattern.match(line.strip())
                    if match:
                        party_str = match.group(1).strip()
                        votes_str = match.group(2).replace(',', '')
                        data.append((current_state, party_str, int(votes_str)))

    return data


def save_data_to_excel(data, output_xlsx):
    """
    Saves a list of (state, party, votes) tuples to an Excel file.
    """
    wb = Workbook()
    ws = wb.active
    ws.title = "Presidential Electors"

    # Header
    ws.append(["State", "Party", "Votes"])

    # Rows
    for row in data:
        ws.append(row)

    wb.save(output_xlsx)


if __name__ == "__main__":
    pdf_file = "2000election.pdf"
    excel_file = "output.xlsx"

    # 1. Extract the data
    elector_data = extract_presidential_elector_data(pdf_file)

    # 2. Write data to Excel
    save_data_to_excel(elector_data, excel_file)

    print("Extraction complete. Data saved to", excel_file)
