"""Open the DuckDB SQL notebook in your browser, connected to warehouse.duckdb.

Run from the project folder:  .venv/bin/python scripts/sql_notebook.py
Stop it with Ctrl+C. (Stop it before running `dbt build`: only one program
can have the database file open for writing at a time.)
"""
import time
from pathlib import Path

import duckdb

DB = Path(__file__).resolve().parent.parent / "warehouse.duckdb"
con = duckdb.connect(str(DB))
con.execute("install ui; load ui; call start_ui_server();")
print("SQL notebook running at http://localhost:4213  (Ctrl+C to stop)")
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    con.execute("call stop_ui_server();")
