import requests

saved_dates = []
full_date = []

def download_pdf(url, save_path):
    try:
        response = requests.get(url)
        response.raise_for_status()  # This will raise an exception if there is an HTTP error

        with open(save_path, 'wb') as f:
            f.write(response.content)

        print(f"PDF saved to {save_path}")

    except requests.exceptions.HTTPError as e:
        # Handle specific HTTP errors or generic ones
        if e.response.status_code == 404:
            print("Error 404: The PDF was not found at the URL provided.")
        else:
            print(f"HTTP error occurred: {e}")
    except Exception as e:
        # Handle other potential errors (e.g., network issues, I/O errors)
        print(f"An error occurred: {e}")

months = ["12"]

for value in months:
    for date in range(1, 32):
        if date < 10:
            scrapedate = value + "0" + str(date)
            saved_dates.append(scrapedate)
        else:
            scrapedate = value + str(date)
            saved_dates.append(scrapedate)
print(saved_dates)

for item in saved_dates:
    date = "2024" + item
    full_date.append(date)

for item in full_date:
    pdf_url = "https://www.niu.edu/publicsafetydept/WebBlotterReports/" + item + "_Offense.pdf"
    save_path = item + ".pdf"
    download_pdf(pdf_url, save_path)
