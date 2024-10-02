USE google_play_store;

SELECT * FROM googleplaystore_CLEAN;
TRUNCATE TABLE googleplaystore_CLEAN;

LOAD DATA INFILE "C:\Users\HP\OneDrive\Desktop\Google_Play_Store_SQL_Project\googleplaystore_CLEAN.csv" 
INTO TABLE googleplaystore_CLEAN
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

/* #	You're working as a market analyst for a mobile app development company.
 Your task is to identify the most promising categories (TOP 5) for launching new free apps based on their average ratings.*/
 
 SELECT Category, ROUND(AVG(Rating),3) AS "Avg_Rating" FROM googleplaystore_CLEAN
 WHERE Type = 'Free'
 GROUP BY Category 
 ORDER BY Avg_Rating DESC 
 LIMIT 5;
 
 /* #	As a business strategist for a mobile app company,
 your objective is to pinpoint the three categories that generate the most revenue from paid apps.
 This calculation is based on the product of the app price and its number of installations.*/
 
 
 SELECT  Category ,SUM((Price * Installs)) AS "REVENUE"  FROM googleplaystore_CLEAN 
 WHERE Type = "Paid"
 GROUP BY Category
 ORDER BY REVENUE DESC
 LIMIT 3;
 
 /* #	As a data analyst for a gaming company, 
 you're tasked with calculating the percentage of apps within each category. 
 This information will help the company understand the distribution of gaming apps across different categories.*/
 
 SELECT *, ((Apps_Count_per_Category)/(SELECT COUNT(*) FROM googleplaystore_CLEAN))*100  AS "Percentage" 
 FROM
 (
SELECT Category , COUNT(App) AS 'Apps_Count_per_Category' FROM googleplaystore_CLEAN 
GROUP BY category
 ) AS a;
 
/* #	As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company 
should develop paid or free apps for each category based on the ratings of that category.*/

WITH code_cte_1 AS 
(
SELECT category, AVG(rating) AS "Paid_App_Rating" FROM googleplaystore_CLEAN WHERE Type = "Paid" GROUP BY category
),
code_cte_2 AS
(
SELECT category, AVG(rating) AS "Free_App_Rating" FROM googleplaystore_CLEAN WHERE Type = "Free" GROUP BY category
)

SELECT category,Paid_App_Rating, Free_App_Rating, if(Paid_App_Rating>Free_App_Rating, "Paid_App", "Free_App") AS "App_Decision" FROM
(
SELECT a.category, Paid_App_Rating, Free_App_Rating
FROM
code_cte_1 AS a 
INNER JOIN 
code_cte_2 AS b
ON a.category = b.category
) AS c;


/* #	Suppose you're a database administrator your databases have been hacked
 and hackers are changing price of certain apps on the database,
 it is taking long for IT team to neutralize the hack, 
 however you as a responsible manager don’t want your data to be changed, 
 do some measure where the changes in price can be recorded as you can’t stop hackers from making changes.*/
 
 -- creating  NEW table to populate after trigger is activated.
CREATE TABLE PriceChangeLog (
    App VARCHAR(255),
    Old_Price DECIMAL(10, 2),
    New_Price DECIMAL(10, 2),
    Operation_Type VARCHAR(10),
    Operation_Date TIMESTAMP
);
 
create table play as                     -- duplicating the current table in use
SELECT * FROM googleplaystore_CLEAN


-- creating a trigger for update functionality on the existing duplicate table.
DELIMITER //   
CREATE TRIGGER price_change_update
AFTER UPDATE ON play                     -- duplicated table
FOR EACH ROW
BEGIN
    INSERT INTO PriceChangeLog (app, old_price, new_price, operation_type, operation_date)  -- adding data to new created table to
    VALUES (NEW.app, OLD.price, NEW.price, 'update', CURRENT_TIMESTAMP);                   -- store changes that will occur after UPDATE
END;
//
DELIMITER ;
 
 
 SET SQL_SAFE_UPDATES = 0;
UPDATE play
SET price = 4
WHERE app = 'Infinite Painter';

UPDATE play
SET price = 5
WHERE app = 'Sketch - Draw & Paint';

SELECT * FROM PriceChangeLog;       -- after UPDATE statements is run TRIGGER get activated and POPULATES the newly created table.



 
 
 /* #	Your IT team have neutralized the threat; however, 
 hackers have made some changes in the prices, 
 but because of your measure you have noted the changes,
 now you want correct data to be inserted into the database again.*/
 
 
SELECT * FROM play AS a
INNER JOIN 
PriceChangeLog AS b 
ON a.App = b.App;

DROP TRIGGER price_change_update;                 -- Need to Drop Trigger as in next step using update statment, if not dropped will again activate the trigger on UPDATE statement

UPDATE play AS a 
INNER JOIN  PriceChangeLog AS b 
ON a.App = b.App
SET a.Price = b.Old_price;

SELECT * FROM play WHERE app='Sketch - Draw & Paint';
SELECT * FROM play WHERE app='Infinite Painter';


/* #	As a data person you are assigned the task of investigating the correlation between two numeric factors:
 app ratings and the quantity of reviews.*/
 
 -- CORRELATION FORMULA: SUM((X-X')*(Y-Y'))/SQRT( SUM((X-X')^2) *  SUM((Y-Y')^2))
 --
 
 
SET @x = (SELECT ROUND(AVG(rating), 2) FROM googleplaystore_CLEAN);
SET @y = (SELECT ROUND(AVG(reviews), 2) FROM googleplaystore_CLEAN);   

WITH code_cte AS
(
	SELECT  *, round((rat_diff*rat_diff),2) AS 'sqr_x' , round((rev_diff*rev_diff),2) AS 'sqr_y' FROM
	(
		SELECT  rating , @x, round((rating- @x),2) AS 'rat_diff' , reviews , @y, round((reviews-@y),2) AS 'rev_diff' FROM googleplaystore_CLEAN
	) AS a
)
 
 -- SELECT * FROM code_cte
 
 SELECT  @numerator := round(sum(rat_diff*rev_diff),2) AS "numerator" , @deno_1 := round(sum(sqr_x),2)  AS "denominator_1", @deno_2:= round(sum(sqr_y),2) AS "denominator_2"  FROM code_cte ;
 

SELECT round((@numerator)/(sqrt(@deno_1*@deno_2)),2) AS corr_coeff;


/* #	Your boss noticed  that some rows in genres columns have multiple genres in them, 
which was creating issue when developing the  recommender system from the data he/she assigned 
you the task to clean the genres column and make two genres out of it, rows that have only one 
genre will have other column as blank.*/

-- function for first part of genre
DELIMITER $$ 
CREATE FUNCTION first_part(a VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC 
BEGIN
	SET @l = LOCATE(';' , a);
    SET @n = IF (@l>0, LEFT(a, @l-1), a);
    
    RETURN @n;
END $$
DELIMITER ;

  -- SELECT first_part('Art & Design;Pretend Play') FROM googleplaystore_CLEAN;

-- function for second part of genre if exist
DELIMITER $$ 
CREATE FUNCTION last_part(a VARCHAR(50))
RETURNS VARCHAR(50)
DETERMINISTIC 
BEGIN
	SET @m = LOCATE(';' , a);
    SET @o = IF(@m = 0,' ', SUBSTRING(a, @m+1, LENGTH(a)));
    
    RETURN @o;
END $$
DELIMITER ;

-- SELECT last_part('Art & Design;Pretend Play') FROM googleplaystore_CLEAN;

SELECT app, genres, first_part(genres) AS 'genre_part_1', last_part(genres) AS 'genre_part_22' FROM googleplaystore_CLEAN;


/* #	Your senior manager wants to know which apps are not performing as par in their particular category,
 however he is not interested in handling too many files or list for every  category and he/she assigned 
 you with a task of creating a dynamic tool where he/she  can input a category of apps he/she  interested in  
 and your tool then provides real-time feedback by displaying apps within that category that have ratings
 lower than the average rating for that specific category.*/
 
 DELIMITER $$
 CREATE PROCEDURE category_name( IN cat VARCHAR(50))
 BEGIN
 
		SET @c = 
		(
			SELECT avg_rating FROM
						(
							SELECT category, ROUND(AVG(rating),3) AS 'avg_rating' FROM googleplaystore_CLEAN GROUP BY category
						) AS a
			WHERE category = cat
		);
      
           SELECT App, category, @c AS 'AVERAGE_RATING' , rating AS 'LOWER_RATING_THAN_AVG' FROM googleplaystore_CLEAN WHERE category = cat AND rating < @c;
END $$
DELIMITER ;
 
 CALL category_name('ART_AND_DESIGN');
 
 
 