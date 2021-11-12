https://www.postgresql.org/docs/9.1/functions-matching.html#FUNCTIONS-POSIX-REGEXP

/* Get the lastest/last position of search text */
SELECT COUNT(*)  FROM regexp_matches('https://images-na.ssl-images-amazon.com/images/I/810CvZ9frfL._SL1500_.jpg', '/', 'g');