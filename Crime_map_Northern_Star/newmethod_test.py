import os
from pdf2image import convert_from_path
from PIL import Image
import pytesseract
import pandas as pd

# Define the folder containing PDFs and the output folder for images
pdf_folder = '/Users/devin/carcrashreader_app/12_24_crimes'
output_csv = '/Users/devin/carcrashreader_app/12_24_cleaned/cleaned_crime_log.csv'
output_raw_csv = '/Users/devin/carcrashreader_app/12_24_cleaned/raw_crime_log.csv'

# Initialize an empty list to store raw extracted data
raw_data = []

# Loop through all PDF files in the folder
for pdf_file in os.listdir(pdf_folder):
    if pdf_file.endswith('.pdf'):
        pdf_path = os.path.join(pdf_folder, pdf_file)

        # Convert PDF to images
        images = convert_from_path(pdf_path, dpi=300)  # Convert each page to an image
        for page_number, image in enumerate(images, start=1):
            # Perform OCR on each image
            text = pytesseract.image_to_string(image)

            # Split text by lines and append to raw_data
            lines = text.split('\n')
            raw_data.extend(lines)

# Save the raw data to a DataFrame and export to CSV
df_raw = pd.DataFrame(raw_data, columns=["Raw Text"])
df_raw.to_csv(output_raw_csv, index=False)

print(f"Raw data extracted and saved to {output_raw_csv}")