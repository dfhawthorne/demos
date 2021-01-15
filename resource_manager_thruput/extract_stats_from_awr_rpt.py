#!/usr/bin/python3
# ------------------------------------------------------------------------------
# Extract statistics of interest from generated AWR reports (HTML)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Import required modules
# ------------------------------------------------------------------------------

try:
    from bs4 import BeautifulSoup
except ModuleNotFoundError as ex:
    print("Run sudo pip3 install bs4")
    exit(1)

try:
    import pandas as pd
except ModuleNotFoundError as ex:
    print("Run sudo pip3 install pandas")
    exit(1)

import os
import statistics
from datetime import datetime

# ------------------------------------------------------------------------------
# Load data from AWR reports
# ------------------------------------------------------------------------------

awr_dir               = "./awr_reports/"
data                  = dict()
data['plan']          = list()
data['num_cpus']      = list()
data['rate']          = list()
data['memory']        = list()
data['platform']      = list()
data['logical_reads'] = list()
data['user_calls']    = list()
data['SQL_executes']  = list()
data['dbid']          = list()
data['startup_time']  = list()
data['snap_time']     = list()

for file_name in os.listdir(awr_dir):
    if not os.path.isfile(awr_dir + file_name):
        continue
    with open(awr_dir + file_name) as fp:
        soup = BeautifulSoup(fp, 'html.parser')

    tables = soup.find_all('table')
    for t in tables:
        if   t.get('summary') == "This table displays pdb instance information":
            rows         = t.find_all('tr')
            cols         = rows[1].find_all('td')
            dbid         = int(cols[0].text)
            startup_time = cols[2].text
        elif t.get('summary') == "This table displays host information":
            rows         = t.find_all('tr')
            cols         = rows[1].find_all('td')
            num_cpus     = int(cols[2].text)
            platform     = cols[1].text
            memory       = float(cols[5].text.replace(',',''))
        elif t.get('summary') == "This table displays snapshot information":
            rows         = t.find_all('tr')
            cols         = rows[2].find_all('td')
            snap_time    = datetime.strptime(cols[2].text, '%d-%b-%y %H:%M:%S')
            cols         = rows[3].find_all('td')
            elapsed_time = float(cols[2].text.split()[0]) * 60.0
        elif t.get('summary') == "This table displays load profile":
            for r in t.find_all('tr'):
                cols = r.find_all('td')
                if   len(cols) >= 2:
                    if   cols[0].text == "Logical read (blocks):":
                        logical_reads = float(cols[1].text.replace(',',''))
                    elif cols[0].text == "User calls:":
                        user_calls    = float(cols[1].text.replace(',',''))
                    elif cols[0].text == "Executes (SQL):":
                        SQL_executes  = float(cols[1].text.replace(',',''))
        elif t.get('summary') == "This table displays top SQL by number of executions":
            for row in t.find_all('tr')[1:]:
                cols = row.find_all('td')
                if cols[6].text == "585dqg3uyuxaj":
                    num_executions = int(cols[0].text.replace(',',''))
                    break
            rate = num_executions/elapsed_time
        elif t.get('summary') == "This table displays name and value of the initialization parametersmodified by the current container":
            resource_manager_plan = "INTERNAL_PLAN"
            for row in t.find_all('tr')[1:]:
                cols = row.find_all('td')
                if cols[0].text == "resource_manager_plan":
                    resource_manager_plan = cols[1].text
                    if resource_manager_plan.strip() == '':
                        resource_manager_plan = "INTERNAL_PLAN"
                    break
            if cols[2].text.strip() == '':
                if resource_manager_plan.startswith("FORCE:"):
                    resource_manager_plan = resource_manager_plan.replace("FORCE:","")
                data['plan'].append(resource_manager_plan)
                data['num_cpus'].append(num_cpus)
                data['rate'].append(rate)
                data['memory'].append(memory)
                data['platform'].append(platform)
                data['logical_reads'].append(logical_reads)
                data['user_calls'].append(user_calls)
                data['SQL_executes'].append(SQL_executes)
                data['dbid'].append(dbid)
                data['startup_time'].append(startup_time)
                data['snap_time'].append(snap_time)
                print(f"File_name='{file_name}',Plan='{resource_manager_plan}',Num CPUs={num_cpus:2d},rate={rate:.2f}")
            else:
                print(f"File_name='{file_name}',Plan changed from '{cols[1].text}' to '{cols[2].text}' - ignored")

# ------------------------------------------------------------------------------
# Analyse data
# ------------------------------------------------------------------------------

frame = pd.DataFrame(data)
frame.to_csv("results.csv")
grouped = frame.groupby(['plan', 'num_cpus']).agg({'rate': ['mean', 'std']})
grouped.columns = ['rate_avg', 'rate_sd']
print(grouped)

