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

# ------------------------------------------------------------------------------
# Load data from AWR reports
# ------------------------------------------------------------------------------

awr_dir          = "./awr_reports/"
data             = dict()
data['plan']     = list()
data['num_cpus'] = list()
data['rate']     = list()

for file_name in os.listdir(awr_dir):
    with open(awr_dir + file_name) as fp:
        soup = BeautifulSoup(fp, 'html.parser')

    tables = soup.find_all('table')
    for t in tables:
        if t.get('summary') == "This table displays host information":
            rows = t.find_all('tr')
            cols = rows[1].find_all('td')
            num_cpus = int(cols[2].text)
        elif t.get('summary') == "This table displays snapshot information":
            rows = t.find_all('tr')
            cols = rows[3].find_all('td')
            elapsed_time = float(cols[2].text.split()[0]) * 60.0
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
                data['plan'].append(resource_manager_plan)
                data['num_cpus'].append(num_cpus)
                data['rate'].append(rate)
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

