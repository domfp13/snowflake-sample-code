USE ROLE SYSADMIN;

-- Create a task to refresh the notebooks.public.xls_table, the underlying query reads from the stream and 
-- uses the oder_date, so_number and manuf_pn as the primary key using a merge statement
CREATE OR REPLACE TASK HACKATHON.PUBLIC.XLS_TABLE_REFRESH_TASK
  WAREHOUSE = HACKATHON_VW
  SCHEDULE = '1 minute'
  WHEN SYSTEM$STREAM_HAS_DATA('HACKATHON.PUBLIC.XLS_TABLE_STAGE_STREAM')
AS
MERGE INTO HACKATHON.PUBLIC.XLS_TABLE T
USING (
  SELECT
       CAST("order_date" AS DATE)                                                               AS order_date,
       CASE WHEN "allocation_date" != 'None' THEN CAST("allocation_date" AS DATE) ELSE NULL END AS allocation_date,
       CAST("so_number" AS INT)                                                                 AS so_number,
       "so_line"                                                                                AS so_line,
       "cust_po"                                                                                AS cust_po,
       "end_user_po"                                                                            AS end_user_po,
       CASE WHEN "account_rep" != '' THEN "account_rep" ELSE NULL END                           AS account_rep,
       "p_line"                                                                                 AS p_line,
       "td_pn"                                                                                  AS td_pn,
       "manuf_pn"                                                                               AS manuf_pn               
  FROM HACKATHON.PUBLIC.XLS_TABLE_STAGE_STREAM
) S
ON T.order_date = S.order_date
AND T.so_number = S.so_number
AND T.manuf_pn = S.manuf_pn
AND T.so_line = S.so_line
WHEN MATCHED THEN
  UPDATE SET
    T.allocation_date = S.allocation_date,
    T.so_line = S.so_line,
    T.cust_po = S.cust_po,
    T.end_user_po = S.end_user_po,
    T.account_rep = S.account_rep,
    T.td_pn = S.td_pn
WHEN NOT MATCHED THEN
  INSERT (
    order_date,
    allocation_date,
    so_number,
    so_line,
    cust_po,
    end_user_po,
    account_rep,
    p_line,
    td_pn,
    manuf_pn
  )
  VALUES (
    S.order_date,
    S.allocation_date,
    S.so_number,
    S.so_line,
    S.cust_po,
    S.end_user_po,
    S.account_rep,
    S.p_line,
    S.td_pn,
    S.manuf_pn
  );

-- Resume the task
ALTER TASK HACKATHON.PUBLIC.XLS_TABLE_REFRESH_TASK RESUME;

-- Execute the task
EXECUTE TASK HACKATHON.PUBLIC.XLS_TABLE_REFRESH_TASK;

-- Check the results in final table
SELECT * FROM HACKATHON.PUBLIC.XLS_TABLE;

-- Check the results in the stream
SELECT * FROM HACKATHON.PUBLIC.XLS_TABLE_STAGE_STREAM;

-- Stop the task
ALTER TASK HACKATHON.PUBLIC.XLS_TABLE_REFRESH_TASK SUSPEND;
