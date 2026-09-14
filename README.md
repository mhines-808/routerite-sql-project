# RouteRite Quote Pipeline — SQL Cleaning & Tableau Dashboard

A data cleaning and analytics project built around RouteRite, a fictional field-service dispatch SaaS company I also built a HubSpot landing page for ([see that project](https://formsandfunnels.com)). This project picks up from the "Get a Quote" form on that page and asks: if this form actually generated a year of leads, what would the sales team need to know?

## What this is

Two related tables — leads and sales — built to match the real fields on the RouteRite quote form (company name, fleet size, current routing method, timeline, lead source), covering a full year of activity. I cleaned the data in MySQL, then built a Tableau dashboard answering a set of real marketing ops questions.

This wasn't a perfectly clean dataset from the start — I deliberately built in the kind of messiness a real export usually has: missing values, inconsistent casing, mixed date formats, a duplicate record, and one clear outlier. Cleaning and documenting those was as much the point of the project as the dashboard itself.

## What's in this repo

- `routerite_dataset.sql` — table creation and the original (unclean) data
- `routerite_cleaning.sql` — the full cleaning workbook, step by step, with comments explaining each decision
- `routerite_export.sql` — the final query used to join and export the cleaned data for Tableau
- `/dashboard` — dashboard screenshots (final PNG export; built on Tableau's free tier, which doesn't support sharing a live/interactive workbook)

## Tools

MySQL, Tableau (free/public tier)

## The cleaning process

- **NULLs** — checked every column, separated honest gaps (optional form fields left blank) from real problems (a missing lead ID). Optional-field NULLs were left as-is in the table and handled with `COALESCE` at report time; the missing lead ID was flagged and excluded from join-based analysis rather than guessed at.
- **Duplicates** — found by grouping on the lead ID. One case turned out to be two different companies that happened to share an ID by data-entry error — since I couldn't confirm which record was correct, I documented it and left both rows rather than guessing. A second, genuine duplicate (same lead, same sale, logged twice) was removed after confirming every field matched.
- **Text standardization** — fixed inconsistent casing and spacing in category fields (lead source, routing method), then rolled up wording differences (e.g., "FB" and "Facebook Ads") into one clean value per category.
- **Dates** — converted a text-formatted submission date column into a real date type.
- **Outliers** — caught one revenue value that was off by several orders of magnitude compared to everything else in the dataset. Since I couldn't verify the correct number, I excluded it from revenue calculations rather than guess at a fix, and documented why.

## The dashboard

Built in Tableau, covering:

- Total leads, closed-won revenue, conversion rate, and average deal size
- Lead volume and revenue by source
- Conversion rate by fleet size and by current routing method
- Revenue vs. conversion rate by fleet size (bigger fleets don't necessarily convert better or close bigger deals — they diverge)
- Salesperson performance — most deals closed vs. highest conversion rate, which aren't always the same person
- Lead volume and revenue trends over the year

## Notes

This is my first full project combining SQL cleaning with a Tableau dashboard, and I built it as practice, not a finished product. The dashboard covers the basics well but I'd like the next one to go further — more detailed tooltips, parameter-driven filtering, and more advanced chart types. Any suggestions or feedback are welcome.
