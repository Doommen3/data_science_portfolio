import pdfplumber
import re
from PyPDF2 import *
import pandas
import pandas as pd
import numpy as np
import os
import csv
from testprocess import *
#from crimesprocessing import *
from crimesprocessing import *

# Path to your PDF file
pdf = pdfplumber.open('/Users/devin/carcrashreader_app/crime_pdfs/20230802.pdf')  # Update this path as necessary


# Function to process each page in the PDF
def process_pdf(path):
    with pdfplumber.open(path) as pdf:
        all_text = []  # List to hold all extracted text
        all_tables = []  # List to hold all extracted tables

        # Loop through each page in the PDF
        for page in pdf.pages:
            # Extract text
            page_text = page.extract_text()
            if page_text:
                all_text.append(page_text)

            # Extract tables with default settings
            page_tables = page.extract_tables()
            for table in page_tables:
                all_tables.append(table)

        return all_text, all_tables

class PDFManager:
    def __init__(self, folder_path):
        self.folder_path = folder_path
        self.pdf_paths = []

    def iterate_pdfs(self):
        # Iterate through all files in the given folder
        for filename in os.listdir(self.folder_path):
            if filename.lower().endswith('.pdf'):  # Check if the file is a PDF
                file_path = os.path.join(self.folder_path, filename)  # Get full path of the file
                self.pdf_paths.append(file_path)
        return self.pdf_paths




# Process the PDF and get text and tables


# Output the extracted text and tables



def main(folder_path):
    test = []
    p = ProcessCrashes()
    #pdf_manager = PDFManager(folder_path)
    #collect_paths = pdf_manager.iterate_pdfs()
    #collect_paths.sort()
    texts_stored = []
    pdf_manager = PDFManager(folder_path)
    collect_paths = pdf_manager.iterate_pdfs()
    collect_paths.sort()

    all_texts = []

    for item in collect_paths:
        texts, tables = process_pdf(item)
        # Add all extracted texts to the all_texts list
        all_texts.extend(texts)

    for text in all_texts:
        # Uncomment these if you need to debug or inspect the texts
        # print("Extracted Text:")
        # print(text)
        test.append(text.split('\n'))

    # After collecting and processing all texts, perform the final processing
    p.process_crashes(test)


# Instantiate read pdf object and pass the transcript

# Call the pdf read function with r object




# Output the accumulated text
    file_path = 'output2_1_25.csv'

    with open(file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        for item in p.complete_frame:
            writer.writerow([item])



if __name__ == '__main__':

    folder_path = "/Users/devin/carcrashreader_app/1_25_crime"
    main(folder_path)

    #pdf_manager = PDFManager(folder_path)
    #collect_paths = pdf_manager.iterate_pdfs()
    #collect_paths.sort()


