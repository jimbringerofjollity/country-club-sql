/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT `name` FROM `Facilities` WHERE `membercost` > 0.0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(*) FROM `Facilities` WHERE `membercost` = 0.0;
/* Output: 4 */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT `facid`, `name`, `membercost`, `monthlymaintenance` FROM `Facilities` WHERE `membercost` > 0.0 AND `membercost` < 0.20 * `monthlymaintenance`;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT * FROM `Facilities` WHERE MOD(`facid`,4) = 1 AND `facid` >= 0 AND `facid` < 9;

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT `name`, `monthlymaintenance`, CASE WHEN `monthlymaintenance` > 100.0 THEN 'expensive' ELSE 'cheap' END AS `budget` FROM `Facilities`;
/* Output:
name             monthlymaintenance  budget
Tennis Court 1   200                 expensive
Tennis Court 2   200                 expensive
Badminton Court  50                  cheap
Table Tennis     10                  cheap
Massage Room 1   3000                expensive
Massage Room 2   3000                expensive
Squash Court     80                  cheap
Snooker Table    15                  cheap
Pool Table       15                  cheap
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT `firstname`, `surname` FROM `Members` WHERE `joindate` = (SELECT MAX(`joindate`) FROM `Members`);
/* Output:
firstname  surname
Darren     Smith
*/

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT(`t`.`name`) AS `tenniscourt`, CONCAT(`m`.`firstname`,' ',`m`.`surname`) AS `member` FROM
(SELECT * FROM `Facilities` AS `f` WHERE `f`.`name` LIKE 'Tennis Court%') AS `t`
LEFT JOIN
(`Bookings` AS `b` RIGHT JOIN `Members` AS `m` ON `b`.`memid` = `m`.`memid`)
ON `t`.`facid` = `b`.`facid`
ORDER BY `member`, `tenniscourt`;
/* First few lines of output:
tenniscourt     member
Tennis Court 1  Anne Baker
Tennis Court 2  Anne Baker
Tennis Court 1  Burton Tracy
Tennis Court 2  Burton Tracy
Tennis Court 1  Charles Owen
Tennis Court 2  Charles Owen
...             ...
*/

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT `f`.`name` AS `facility`, CONCAT(`m`.`firstname`,' ',`m`.`surname`) AS `member`,
CASE WHEN `m`.`memid` = 0 THEN `f`.`guestcost`*`b`.`slots` ELSE `f`.`membercost`*`b`.`slots` END AS `cost`
FROM `Facilities` AS `f`
RIGHT JOIN
`Bookings`  AS `b` LEFT JOIN `Members` AS `m` ON `b`.`memid` = `m`.`memid`
ON `f`.`facid` = `b`.`facid`
WHERE `b`.`starttime` BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59' AND
((`m`.`memid` = 0 AND `f`.`guestcost`*`b`.`slots` > 30.0) OR (`m`.`memid` != 0 AND `f`.`membercost`*`b`.`slots` > 30.0))
ORDER BY `cost` DESC, `b`.`starttime`, `member`;
/* Output:
facility        member          cost
Massage Room 2  GUEST GUEST    320.0
Massage Room 1  GUEST GUEST    160.0
Massage Room 1  GUEST GUEST    160.0
Massage Room 1  GUEST GUEST    160.0
Tennis Court 2  GUEST GUEST    150.0
Tennis Court 2  GUEST GUEST     75.0
Tennis Court 1  GUEST GUEST     75.0
Tennis Court 1  GUEST GUEST     75.0
Squash Court    GUEST GUEST     70.0
Massage Room 1  Jemima Farrell  39.6
Squash Court    GUEST GUEST     35.0
Squash Court    GUEST GUEST     35.0
*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT `f`.`name` AS `facility`, CONCAT(`m`.`firstname`,' ',`m`.`surname`) AS `member`,
CASE WHEN `m`.`memid` = 0 THEN `f`.`guestcost`*`q`.`slots` ELSE `f`.`membercost`*`q`.`slots` END AS `cost`
FROM `Facilities` AS `f`
RIGHT JOIN
(SELECT * FROM `Bookings` WHERE `starttime` BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59') AS `q`
LEFT JOIN `Members` AS `m` ON `q`.`memid` = `m`.`memid`
ON `f`.`facid` = `q`.`facid`
WHERE ((`m`.`memid` = 0 AND `f`.`guestcost`*`q`.`slots` > 30.0) OR (`m`.`memid` != 0 AND `f`.`membercost`*`q`.`slots` > 30.0))
ORDER BY `cost` DESC, `q`.`starttime`, `member`;
/* Output:
facility        member          cost
Massage Room 2  GUEST GUEST    320.0
Massage Room 1  GUEST GUEST    160.0
Massage Room 1  GUEST GUEST    160.0
Massage Room 1  GUEST GUEST    160.0
Tennis Court 2  GUEST GUEST    150.0
Tennis Court 2  GUEST GUEST     75.0
Tennis Court 1  GUEST GUEST     75.0
Tennis Court 1  GUEST GUEST     75.0
Squash Court    GUEST GUEST     70.0
Massage Room 1  Jemima Farrell  39.6
Squash Court    GUEST GUEST     35.0
Squash Court    GUEST GUEST     35.0
*/

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions. */
import pandas as pd
import sqlite3
con = sqlite3.connect('sqlite_db_pythonsqlite.db')

/* QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
q10 = pd.read_sql_query('SELECT * FROM'
'(SELECT `f`.`name` AS `facility`,'
'SUM(CASE WHEN `b`.`memid` = 0 THEN `f`.`guestcost`*`b`.`slots` ELSE `f`.`membercost`*`b`.`slots` END) AS `revenue`'
'FROM `Bookings`  AS `b`'
'LEFT JOIN `Facilities` AS `f`'
'ON `f`.`facid` = `b`.`facid`'
'LEFT JOIN `Members` AS `m`'
'ON `b`.`memid` = `m`.`memid`'
'GROUP BY `facility`'
'ORDER BY `revenue`) AS `q`'
'WHERE `revenue` < 1000.0', con)
print(q10)
/* Output:
        facility  revenue
0   Table Tennis      180
1  Snooker Table      240
2     Pool Table      270
*/

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
q11 = pd.read_sql_query('SELECT `m`.`surname` AS `member surname`, `m`.`firstname` AS `member firstname`,'
'`q`.`surname` AS `recommended`, `q`.`firstname` AS `by`'
'FROM `Members` AS `m`'
'LEFT JOIN (SELECT `memid`, `firstname`, `surname` FROM `Members`) AS `q`'
'ON `m`.`recommendedby` = `q`.`memid`'
'WHERE `q`.`memid` != 0', con)
print(q11)
/* Output:
       member surname member firstname recommended         by
0            Joplette           Janice       Smith     Darren
1             Butters           Gerald       Smith     Darren
2                Dare            Nancy    Joplette     Janice
3              Boothe              Tim      Rownam        Tim
4            Stibbons           Ponder       Tracy     Burton
5                Owen          Charles       Smith     Darren
6               Jones            David    Joplette     Janice
7               Baker             Anne    Stibbons     Ponder
8               Smith             Jack       Smith     Darren
9               Bader         Florence    Stibbons     Ponder
10              Baker          Timothy     Farrell     Jemima
11             Pinker            David     Farrell     Jemima
12            Genting          Matthew     Butters     Gerald
13          Mackenzie             Anna       Smith     Darren
14             Coplin             Joan       Baker    Timothy
15             Sarwin        Ramnaresh       Bader   Florence
16              Jones          Douglas       Jones      David
17             Rumney        Henrietta     Genting    Matthew
18  Worthington-Smyth            Henry       Smith      Tracy
19            Purview        Millicent       Smith      Tracy
20               Hunt             John     Purview  Millicent
21            Crumpet            Erica       Smith      Tracy
*/

/* Q12: Find the facilities with their usage by member, but not guests */
q12 = pd.read_sql_query('SELECT `facility`, `firstname`, `surname`, `usage` FROM'
'(SELECT `f`.`name` AS `facility`,`m`.`memid`,`m`.`firstname`, `m`.`surname`,'
'SUM(`b`.`slots`) AS `usage`'
'FROM `Bookings`AS `b`'
'LEFT JOIN `Facilities` AS `f`'
'ON `f`.`facid` = `b`.`facid`'
'LEFT JOIN `Members` AS `m`'
'ON `b`.`memid` = `m`.`memid`'
'GROUP BY `m`.`memid`'
'ORDER BY `f`.`facid`)'
'WHERE `memid` != 0', con)
print(q12)
/* Output:
           facility  firstname            surname  usage
0    Tennis Court 1      Tracy              Smith    435
1    Tennis Court 1     Gerald            Butters    409
2    Tennis Court 1    Charles               Owen    345
3    Tennis Court 1       Anne              Baker    296
4    Tennis Court 1      David            Farrell     50
5    Tennis Court 1       John               Hunt     40
6    Tennis Court 2     Burton              Tracy    366
7    Tennis Court 2        Tim             Boothe    440
8    Tennis Court 2     Ponder           Stibbons    249
9    Tennis Court 2      David              Jones    305
10   Tennis Court 2    Timothy              Baker    290
11   Tennis Court 2  Ramnaresh             Sarwin    153
12  Badminton Court      Nancy               Dare    267
13  Badminton Court   Florence              Bader    237
14  Badminton Court       Anna          Mackenzie    231
15  Badminton Court    Douglas              Jones     37
16  Badminton Court      Henry  Worthington-Smyth     60
17  Badminton Court  Millicent            Purview     32
18  Badminton Court      Erica            Crumpet     17
19     Table Tennis     Darren              Smith    685
20     Table Tennis     Jemima            Farrell    180
21   Massage Room 1        Tim             Rownam    660
22   Massage Room 1     Janice           Joplette    326
23   Massage Room 1       Jack              Smith    219
24   Massage Room 2    Matthew            Genting    131
25    Snooker Table      David             Pinker    159
26    Snooker Table       Joan             Coplin    106
27    Snooker Table  Henrietta             Rumney     38
28    Snooker Table   Hyacinth         Tupperware     28
*/

/* Q13: Find the facilities usage by month, but not guests */
q13 = pd.read_sql_query(''
'SELECT `f`.`name` AS `facility`,'
'SUBSTR(`b`.`starttime`,1,7) AS `month`,'
'SUM(CASE WHEN `b`.`memid` = 0 THEN 0 ELSE `b`.`slots` END) AS `usage`'
'FROM `Bookings` AS `b`'
'LEFT JOIN `Facilities` AS `f`'
'ON `f`.`facid` = `b`.`facid`'
'LEFT JOIN `Members` AS `m`'
'ON `b`.`memid` = `m`.`memid`'
'GROUP BY `f`.`facid`,`month`'
'ORDER BY `f`.`facid`,`month`', con)
print(q13)
/* Output:
           facility    month  usage
0    Tennis Court 1  2012-07    201
1    Tennis Court 1  2012-08    339
2    Tennis Court 1  2012-09    417
3    Tennis Court 2  2012-07    123
4    Tennis Court 2  2012-08    345
5    Tennis Court 2  2012-09    414
6   Badminton Court  2012-07    165
7   Badminton Court  2012-08    414
8   Badminton Court  2012-09    507
9      Table Tennis  2012-07     98
10     Table Tennis  2012-08    296
11     Table Tennis  2012-09    400
12   Massage Room 1  2012-07    166
13   Massage Room 1  2012-08    316
14   Massage Room 1  2012-09    402
15   Massage Room 2  2012-07      8
16   Massage Room 2  2012-08     18
17   Massage Room 2  2012-09     28
18     Squash Court  2012-07     50
19     Squash Court  2012-08    184
20     Squash Court  2012-09    184
21    Snooker Table  2012-07    140
22    Snooker Table  2012-08    316
23    Snooker Table  2012-09    404
24       Pool Table  2012-07    110
25       Pool Table  2012-08    303
26       Pool Table  2012-09    443
*/

/* Close the connection */
con.close()
