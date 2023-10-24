USE ROLE SYSADMIN;
USE DATABASE HACKATHON;
USE SCHEMA PUBLIC;
USE WAREHOUSE HACKATHON_VW;

CREATE OR REPLACE PROCEDURE HACKATHON.PUBLIC.XLS_LOADER_SP(file_path string)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'xlrd')
HANDLER = 'main'
COMMENT = 'Created by Enrique Plata, this procedure reads and loads an xls file to a table'
EXECUTE AS CALLER
AS
$$
import xlrd
import pandas as pd
from snowflake.snowpark.files import SnowflakeFile
from datetime import datetime

class FileFormat:
    def __init__(self, order_date: str, allocation_date: str, so_number: str, so_line: str, cust_po: str, end_user_po: str, account_rep: str, p_line: str, td_pn: str, manuf_pn: str):
        self.order_date = order_date
        self.allocation_date = allocation_date
        self.so_number = so_number
        self.so_line = so_line
        self.cust_po = cust_po
        self.end_user_po = end_user_po
        self.account_rep = account_rep
        self.p_line = p_line
        self.td_pn = td_pn
        self.manuf_pn = manuf_pn

    @staticmethod
    def keys():
        return ['order_date', 'allocation_date', 'so_number', 'so_line', 'cust_po', 'end_user_po', 'account_rep', 'p_line', 'td_pn', 'manuf_pn']

    def values(self):
        return self.__dict__

    def __del__(self):
        "This (Magic/Dunder) method deletes the object from memory"
        pass

def main(session, file_path):
    with SnowflakeFile.open(file_path, 'rb') as file:
        binary_data = file.read()

    workbook = xlrd.open_workbook(file_contents=binary_data, on_demand=True)

    worksheet = workbook.sheet_by_index(0)

    data = []

    for row in range(1, worksheet.nrows):
        
        order_date = worksheet.cell(row, 0).value
        if order_date == '':
            order_date = None
        else:
            order_date = datetime(*xlrd.xldate_as_tuple(order_date, workbook.datemode)).strftime('%Y-%m-%d')
        
        allocation_date = worksheet.cell(row, 1).value
        if allocation_date == '':
            allocation_date = None
        else:
            allocation_date = datetime(*xlrd.xldate_as_tuple(allocation_date, workbook.datemode)).strftime('%Y-%m-%d')
        
        file_row = FileFormat(
            order_date=order_date,
            allocation_date=allocation_date,
            so_number=worksheet.cell(row, 2).value,
            so_line=worksheet.cell(row, 3).value,
            cust_po=worksheet.cell(row, 4).value,
            end_user_po=worksheet.cell(row, 5).value,
            account_rep=worksheet.cell(row, 6).value,
            p_line=worksheet.cell(row, 7).value,
            td_pn=worksheet.cell(row, 8).value,
            manuf_pn=worksheet.cell(row, 9).value
        )

        data.append(file_row.values())

    df = pd.DataFrame(data, columns=FileFormat.keys()).astype(str)

    snowpark_df = session.create_dataframe(df)

    # Truncate the table
    session.sql("TRUNCATE TABLE HACKATHON.PUBLIC.XLS_TABLE_STAGE").collect()

    # Load data
    snowpark_df.write.mode("append").save_as_table("HACKATHON.PUBLIC.XLS_TABLE_STAGE")

    return "Succeeded"

$$;

-- 1.- Load file in stage

-- 2.- Call procedure
CALL HACKATHON.PUBLIC.XLS_LOADER_SP(BUILD_SCOPED_FILE_URL(@HACKATHON.PUBLIC.XLS_LAKE,'/testing.xls'));

-- 3.- Check results
SELECT * FROM HACKATHON.PUBLIC.XLS_TABLE_STAGE;

-- 4.- Check results in stream (stream is capturing the changes in the table)
SELECT * FROM HACKATHON.PUBLIC.XLS_TABLE_STAGE_STREAM;
