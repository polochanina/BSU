REM   Script: Lab 2
REM   lab 2

-- Task 1 - Результирующее множество
SELECT EMPCOUNT, JOBNAME FROM JOB JOIN (SELECT COUNT(EMPNO) AS EMPCOUNT, JOBNO FROM CAREER   
GROUP BY JOBNO ORDER BY JOBNO DESC) USING(JOBNO);

-- Task 1 - Разворачивание результирующего множества в одну строку
-- Развернуть группу строк информирующую о количестве сотрудников на каждой
должности в настоящий момент времени, превращая их значения в столбцы.
SELECT SUM(CASE WHEN JOBNAME='PRESIDENT' THEN 1 ELSE 0 END) AS PRESIDENT,   
SUM(CASE WHEN JOBNAME='DRIVER' THEN 1 ELSE 0 END) AS DRIVER,    
SUM(CASE WHEN JOBNAME='CLERK' THEN 1 ELSE 0 END) AS CLERK,    
SUM(CASE WHEN JOBNAME='SALESMAN' THEN 1 ELSE 0 END) AS SALESMAN,    
SUM(CASE WHEN JOBNAME='EXECUTIVE DIRECTOR' THEN 1 ELSE 0 END) AS EXECUTIVE_DIRECTOR,    
SUM(CASE WHEN JOBNAME='FINANCIAL DIRECTOR' THEN 1 ELSE 0 END) AS FINANCIAL_DIRECTOR,   
SUM(CASE WHEN JOBNAME='MANAGER' THEN 1 ELSE 0 END) AS MANAGER    
FROM (SELECT EMPNO, JOBNAME FROM JOB JOIN CAREER USING(JOBNO));

-- Task 2 - Разворачивание результирующего множества в несколько строк
-- Требуется преобразовать строки в столбцы, создавая для каждого значения
заданного столбца отдельный столбец.
SELECT MAX(CASE WHEN DEPTNAME='ACCOUNTING' THEN EMPNAME ELSE NULL END) AS ACCOUNTING,  
MAX(CASE WHEN DEPTNAME='OPERATIONS' THEN EMPNAME ELSE NULL END) AS OPERATIONS,  
MAX(CASE WHEN DEPTNAME='RESEARCH' THEN EMPNAME ELSE NULL END) AS RESEARCH,  
MAX(CASE WHEN DEPTNAME='SALES' THEN EMPNAME ELSE NULL END) AS SALES  
FROM (SELECT DEPTNAME, EMPNAME, ROW_NUMBER() OVER(PARTITION BY DEPTNAME ORDER BY EMPNAME) RN   
FROM DEPT JOIN CAREER USING(DEPTNO) JOIN EMP USING(EMPNO))  
GROUP BY RN;

-- Task 3 - Обратное разворачивание результирующего множества
-- Выполните обратное разворачивание для результирующего множества, полученного в задании 1
SELECT J.JOBNAME,   
CASE J.JOBNAME   
WHEN 'MANAGER' THEN EMP_CNTS.MANAGER  
WHEN 'FINANCIAL DIRECTOR' THEN EMP_CNTS.FINANCIAL_DIRECTOR  
WHEN 'EXECUTIVE DIRECTOR' THEN EMP_CNTS.EXECUTIVE_DIRECTOR  
WHEN 'SALESMAN' THEN EMP_CNTS.SALESMAN  
WHEN 'CLERK' THEN EMP_CNTS.CLERK  
WHEN 'DRIVER' THEN EMP_CNTS.DRIVER  
WHEN 'PRESIDENT' THEN EMP_CNTS.PRESIDENT  
END AS EMPCOUNT  
FROM (SELECT SUM(CASE WHEN JOBNAME='PRESIDENT' THEN 1 ELSE 0 END) AS PRESIDENT,  
SUM(CASE WHEN JOBNAME='DRIVER' THEN 1 ELSE 0 END) AS DRIVER,   
SUM(CASE WHEN JOBNAME='CLERK' THEN 1 ELSE 0 END) AS CLERK,   
SUM(CASE WHEN JOBNAME='SALESMAN' THEN 1 ELSE 0 END) AS SALESMAN,   
SUM(CASE WHEN JOBNAME='EXECUTIVE DIRECTOR' THEN 1 ELSE 0 END) AS EXECUTIVE_DIRECTOR,   
SUM(CASE WHEN JOBNAME='FINANCIAL DIRECTOR' THEN 1 ELSE 0 END) AS FINANCIAL_DIRECTOR,  
SUM(CASE WHEN JOBNAME='MANAGER' THEN 1 ELSE 0 END) AS MANAGER   
FROM (SELECT EMPNO, JOBNAME FROM JOB JOIN CAREER USING(JOBNO))) EMP_CNTS,   
(SELECT JOBNAME FROM JOB) J;

-- Task 4 - Обратное разворачивание результирующего множества в один столбец
-- Составьте запрос, который будет выполнять обратное разворачивание результирующего множества в один столбец.
SELECT CASE RN 
WHEN 1 THEN CAST(JOBNO AS CHAR(4)) 
WHEN 2 THEN JOBNAME 
WHEN 3 THEN CAST(MINSALARY AS CHAR(10)) 
END JOBS 
FROM (SELECT JOBNO, JOBNAME, MINSALARY, ROW_NUMBER() OVER(PARTITION BY JOBNO ORDER BY JOBNO) RN  
FROM JOB J, (SELECT * FROM DEPT) FOUR_ROWS);

-- Task 5 - Исключение повторяющихся значений из результирующего множества
-- Составьте запрос, который будет исключать повторяющиеся значения из результирующего множества.
SELECT DECODE(LAG(JOBNAME) OVER(ORDER BY JOBNAME), JOBNAME, NULL, JOBNAME) JOBNAME, EMPNO FROM CAREER JOIN JOB USING(JOBNO);

-- Example 6
-- Требуется вычислить разность между заработными платами DEPTNO 30 и DEPTNO
10 и заработными платами DEPTNO 10 и DEPTNO 40.
Таким образом, требуется выполнить вычисления, в которых участвуют данные
нескольких строк. Чтобы упростить задачу, эти строки надо развернуть и превратить
в столбцы, так чтобы все необходимые значения располагались в одной строке.
SELECT D30_SAL - D10_SAL AS D30_D10_DIF, D10_SAL - D40_SAL AS D10_D40_DIF 
FROM (SELECT SUM(CASE WHEN DEPTNO=10 THEN SALVALUE END) AS D10_SAL, 
SUM(CASE WHEN DEPTNO=30 THEN SALVALUE END) AS D30_SAL, 
SUM(CASE WHEN DEPTNO=40 THEN SALVALUE END) AS D40_SAL 
FROM EMP JOIN SALARY USING(EMPNO) JOIN CAREER USING(EMPNO) JOIN JOB USING(JOBNO) JOIN DEPT USING(DEPTNO)) TOTALS_BY_DEPT;
