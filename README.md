<h1 align="center">Data Science Portfolio</h1>

<p align="center">A portfolio and archive of coursework, research, and applied data projects by Devin Oommen.</p>

## Overview

This repository collects statistics, data-engineering, and visualization work spanning academic research and applied tooling — from an honors thesis built on a 484,630-village dataset to web-scraping pipelines and interactive R/Shiny apps. It serves as an archive of foundational projects; the most polished pieces have since graduated into their own standalone repositories (linked below).

## Highlights

### Consequences and Determinants of Electrification in India — Honors Thesis

The standout project: a 16-week independent-study honors thesis advised by a political science professor at Northern Illinois University, examining how village-level electrification affects socioeconomic welfare across rural India.

- **Scale.** Cross-sectional analysis of **484,630 Indian villages** using the Socioeconomic High Resolution Urban Geographic (SHRUG) dataset.
- **Method.** Multiple linear regression in R (with `sf` for spatial data), controlling for income, poverty rates, gender composition, and land ownership.
- **Findings.** Access to domestic electricity is associated with a **~1.6% increase** in estimated monthly per-capita consumption (a welfare proxy), with the model achieving an **R² of 0.82**. Commercial electrification showed no significant effect, and higher-income villages were more likely to capture the benefits — pointing to distributional inequities in access.
- **Rigor.** Grounded in academic literature with full citations, and **accepted for presentation at the Midwest Political Science Association (MPSA)** conference.

The complete write-up, R analysis scripts, spatial maps, and references live in [`Consequences and Determinants of Electrification in India`](./Consequences%20and%20Determinants%20of%20Electrification%20in%20India/Independentstudy_honorsproject).

## Projects in this repo

- **[Consequences and Determinants of Electrification in India](./Consequences%20and%20Determinants%20of%20Electrification%20in%20India/Independentstudy_honorsproject)** — Honors thesis (above).
- **[Crime_map_Northern_Star](./Crime_map_Northern_Star)** — A pipeline that scrapes NIU's monthly campus crime logs (previously transcribed by hand) out of PDFs, geocodes them, and visualizes the incidents on a map. Python + R/Shiny.
- **[Crop_simulation](./Crop_simulation)** — A Stat 415 (Computational Methods in Statistics) final project simulating agricultural yields under a Latin-square experimental design, running the experiment seven ways and plotting yield distributions. R.
- **[WorkoutVizApp](./WorkoutVizApp)** — An R/Shiny app for visualizing weekly exercise data by body part and movement.
- **[vote_total_scraping](./vote_total_scraping)** — Collecting and cleaning U.S. presidential election vote totals by state from source PDFs into structured datasets, for a faculty research project. Python.

## Polished standalone repos

Several projects have evolved into dedicated, production-grade repositories:

- **[Follow The Money IL](https://github.com/Doommen3/Illinois_campaign_finance)** — Illinois campaign-finance data.
- **[Legislative Bill Stats](https://github.com/Doommen3/congress-bill-stats)** — Congressional bill statistics.
- **[DeKalb Scanner Alerts](https://github.com/Doommen3/police_scanner_transcription)** — Police-scanner transcription and alerting.
- **[NIU Crime Map](https://github.com/Doommen3/Crimelogreader)** — The polished successor to `Crime_map_Northern_Star`.

## Author

**Devin Oommen** — [devinoommen.com](https://devinoommen.com) · Oommen & Company

## License

Released under the [MIT License](./LICENSE).
