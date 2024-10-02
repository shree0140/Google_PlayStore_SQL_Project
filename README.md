# PROJECT:  Google Play Store Analysis using SQL.

## Overview:
This project focuses on analyzing data from the Google Play Store using SQL, with the initial data cleaning performed in Jupyter Notebook using Python. The project addresses the following key business problems:

- **Top Categories for Free Apps:** Identified the five most promising categories for launching new free apps based on their average ratings, guiding future app development strategies.

- **Top Revenue-Generating Categories:** Pinpointed the three categories that generate the highest revenue from paid apps by calculating revenue as a product of app price and installations.

- **Game Distribution Analysis:** Calculated the percentage of gaming apps in each category to understand the distribution and market penetration of games.

- **Recommendation on Paid vs Free Apps:** Recommended whether to develop paid or free apps for each category based on the average ratings of the apps in that category.

- **Data Integrity and Security:** Implemented measures to track changes in app prices when a hacking incident occurred, ensuring data integrity and allowing the restoration of correct prices after neutralizing the threat.

- **Correlation Analysis:** Investigated the correlation between app ratings and the number of reviews to uncover insights on user feedback and engagement.

- **Genres Column Cleanup:** Cleaned the "genres" column, separating rows with multiple genres into two columns for better classification, ensuring smoother processing for a recommender system.

- **Dynamic Tool for Identifying Underperforming Apps:** Developed a tool that allows the input of a category to dynamically display apps within that category with below-average ratings, helping managers track underperforming apps in real-time.

This comprehensive analysis helps inform decision-making across multiple aspects of app development, security, and performance optimization.