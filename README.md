# institutional-financial-analyses

Model the financial health of postsecondary institutions using IPEDS and other federal data.

Stress Scores estimated based on methods recommended in Appendix A from:

Zemsky, R., Shaman, S., Campbell Baldridge, S. (2020). _The College Stress Test: Tracking Institutional Futures across a Crowded Market_. Johns Hopkins University Press.  Baltimore, Maryland.

## Using This Repo

The script(s) in this project utilize a SQLite db that is created in the root directory by the script **db_setup.R**.  _You should only need to run this script once_.

The main script is **zemsky_stress_scores_nces.Rmd** and will access the SQLite database that was created in the previous step.  It analyzes an eight-year window of data ending with the collection year set in the parameter _year_ at the top of the page.  It outputs two datafiles:

* _metrics.csv_: contains each institution's metric values for all eight years that are analyzed.
* _stress.csv_: stress scores for each institution.

The second script, **ipeds_financial_metrics_nces.Rmd** uses the database to create more traditional financial metrics for publics and privates.  It does a _naive_ union of FASB and GASB information -- for example, treating the debt measures as a single measure and overlooking differences in unfunded and unrestricted for financial aid allowances.  For simple listings, it should give a "quick and dirty" indication of institutions that may be under duress during the crisis.  This script produces the file _ipeds_metrics.csv_, which you will find in the /data directory after running.

RStudio will also knit an HTML version of the each notebook in the project directory.

## Built With

* R 3.6.3
* RStudio Version 1.2.5033

## Dependencies

* broom     0.5.5
* DBI       1.1.0
* dbplyr    1.4.2
* dplyr     0.8.5
* forcats   0.5.0
* ggplot2   3.3.0
* lubridate 1.7.8
* odbc      1.2.2
* purrr     0.3.3
* readr     1.3.1
* RSQLite   2.2.0
* stringr   1.4.0
* tibble    3.0.0
* tidyr     1.0.2

## Versioning

1.0

## Author

* **Jason Casey**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

