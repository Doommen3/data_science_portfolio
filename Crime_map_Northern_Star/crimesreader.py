from PyPDF2 import *
import pandas
import pandas as pd
import numpy as np
import os
import csv
#from crimesprocessing import *
from crimesprocessing import *

class read_pdf:

    def __init__(self, pdf_data="Offense.pdf"):
        self.reader = PdfReader(pdf_data)
        self.num_pages = len(self.reader.pages)
        self.process = None
        self.complete_myframe = []
        self.extracted_text = None
        self.full_list = []
        self.list_to_process = []
        self.startIndex = []
        self.startWords = ["WEATHER", "TOTALS", "TYPE"]
        self.list_to_send = []
        self.folder_path = "/Users/devin/carcrashreader_app/crime_pdfs"
        self.pdf_paths = []


    def updateProcess(self, process):
        """Sets the self.process variable to the list pass through parameter"""
        self.process = process
        self.con = True


    def pdf_read(self):
        """Reads a pdf file"""
        start_index = []
        # Iterates through each page in the pdf
        for page_num in range(0, self.num_pages):

            # Stores text extracted from the file to the page variable
            page = (self.reader.pages[page_num]).extract_text(Tj_sep=" ", TJ_sep="\n")


            # Splits the text from the page variable into a group of lists and stores it in the extracted_text variable
            self.extracted_text = page.split()

            # for every page, extract the text
            for num in range(0, len(self.extracted_text)):
                self.full_list.append(self.extracted_text[num])
            print(f"this is full list {self.full_list}")

        # Find the indexes that the lines should start
        for item in range(0, len(self.full_list)):
            if len(self.full_list[item]) == 12 or len(self.full_list[item]) == 13 and str(
                    self.full_list[item]).isnumeric():
                start_index.append(item)

        for item2 in range(0, len(start_index)):
            if item2 < len(start_index) - 1:
                process = self.full_list[start_index[item2]: start_index[item2 + 1]]
                for num1 in range(0, len(process)):
                    self.list_to_send.append(process[num1])
            if item2 == len(start_index) - 1:
                process = self.full_list[start_index[item2]:]
                for num1 in range(0, len(process)):
                    self.list_to_send.append(process[num1])


                #process_pdf(file_path)  # Call your function to process the PDF


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



def main(folder_path):
    p = ProcessGrades()
    pdf_manager = PDFManager(folder_path)
    collect_paths = pdf_manager.iterate_pdfs()
    collect_paths.sort()

    for item in collect_paths:

    # Instantiate read pdf object and pass the transcript
        r = read_pdf(item)
    # Call the pdf read function with r object
        r.pdf_read()
        p.process_classes(r.list_to_send)
    # Output the accumulated text
    print(p.complete_myframe)
    file_path = 'output.csv'

    with open(file_path, mode='w', newline='') as file:
        writer = csv.writer(file)
        for item in p.complete_myframe:
            writer.writerow([item])

if __name__ == '__main__':

    folder_path = "/Users/devin/carcrashreader_app/12_24_crimes"
    main(folder_path)

