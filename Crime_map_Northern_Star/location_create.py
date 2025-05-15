import pandas as pd
from geopy.geocoders import GoogleV3
from geopy.extra.rate_limiter import RateLimiter

# Read data from CSV
df = pd.read_csv('/Users/devin/NIU_CrimeLogReader/final_crimelogcsv_1_25_cleaned.csv')  # Replace with your CSV file name

API_KEY = 'AIzaSyDi01tK05t4_RTIaTPUmFwIVorYFJHNH_I'

# Hardcoded addresses for known places
hardcoded_addresses = {
    'DeKalb Public Library': '309 Oak St, DeKalb, IL 60115, USA',
    'NIU Campus': '1425 W Lincoln Hwy, DeKalb, IL 60115, USA',
    'Lot P': '455 Stadium Dr W, DeKalb, IL 60115, USA',
    'Health, Wellness, & Literacy Center ': '3100 Sycamore Rd, DeKalb, IL 60115, USA',
    'Patterson Hall East': '501 N Annie Glidden Rd, DeKalb, IL 60115, USA',
    'Lot 3': '300 Gilbert Dr, DeKalb, IL 60115, USA',
    'Lot S': '212 N Annie Glidden Rd, DeKalb, IL 60115, USA',
    'Recreation Center': '325 N Annie Glidden Rd, DeKalb, IL 60115, USA',
    'Music Building': '550 Lucinda Ave, DeKalb, IL 60115, USA',
    'Culvers': '1200 Dekalb Ave, DeKalb, IL 60115, USA',
    'Neptune North': '750 Lucinda Ave, DeKalb, IL 60115, USA',
    'Lot 5': '532 Newman Ln, DeKalb, IL 60115, USA',
    'Human Resources': '1515 W Lincoln Hwy, DeKalb, IL 60115, USA',
    'Grant Complex': '1250 Grant Dr N, DeKalb, IL 60115, USA',
    'Stevenson South': '420 Stadium Dr W, DeKalb, IL 60115, USA',
    'Grant North': '1250 Grant Dr N, DeKalb, IL 60115, USA',
    'Lot D': '830 Lucinda Ave, DeKalb, IL 60115, USA',
    'Stevenson Complex': '1350 Stevenson Dr N, DeKalb, IL 60115, USA',
    'Patternson Hall West': '1175 Lincoln Dr N, DeKalb, IL 60115, USA',
    'Swen Parson': '230 Normal Rd, DeKalb, IL 60115, USA',
    'Neptune West': '800 Lucinda Ave, DeKalb, IL 60115, USA',
    'Altgeld Hall': '595 College Ave, DeKalb, IL 60115, USA',
    'Lot X': '615 N Annie Glidden Rd, DeKalb, IL 60115, USA',
    'Stevenson  North': '1350 Stevenson Dr N, DeKalb, IL 60115, USA',
    'Parking Deck': '175 Normal Rd, DeKalb, IL 60115, USA',
    'Neptune Complex': '770 Lucinda Ave, DeKalb, IL 60115, USA',
    'Psychology / Computer Science': '100 Normal Rd, DeKalb, IL 60115, USA',
    'Stevenson North': '1350 Stevenson Dr N, DeKalb, IL 60115, USA',
    'Northern View': '1 Northern View Circle, DeKalb, IL 60115, USA',
    'Lot C': '890 Lucinda Avenue, DeKalb, IL 60115, USA',
    'Gilbert Hall': '383 Gilbert Drive, DeKalb, IL 60115, USA'

}

# Initialize Google geocoder
geolocator = GoogleV3(api_key=API_KEY)
geocode = RateLimiter(geolocator.geocode, min_delay_seconds=1)


# Function to get address, latitude, and longitude
def get_address_and_coords(place):
    if place in hardcoded_addresses:
        address = hardcoded_addresses[place]
        location = geocode(address)
    else:
        location = geocode(place)
        address = location.address if location else "Address not found"

    if location:
        latitude = location.latitude
        longitude = location.longitude
    else:
        latitude, longitude = None, None

    return pd.Series([address, latitude, longitude])


# Apply function to get full address, latitude, and longitude
df[['Full_Address', 'Latitude', 'Longitude']] = df['Current_Column'].apply(get_address_and_coords)

# Save the updated data to a new CSV file
df.to_csv('updated_crime_data_google_with_coords_1_25.csv', index=False)
print("Data with latitude and longitude saved to 'updated_crime_data_google_with_coords_1_25.csv'")
