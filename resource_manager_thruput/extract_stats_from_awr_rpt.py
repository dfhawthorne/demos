#!/usr/bin/python3
# ------------------------------------------------------------------------------
# Extract statistics of interest from generated AWR reports (HTML)
# ------------------------------------------------------------------------------

try:
    from bs4 import BeautifulSoup
except ModuleNotFoundError as ex:
    print("Run sudo pip3 install bs4")
    exit(1)

import os
import statistics

awr_dir = "./awr_reports/"
internal_plan = list()
default_plan  = list()
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
            if resource_manager_plan == "INTERNAL_PLAN":
                internal_plan.append(rate)
            elif resource_manager_plan == "DEFAULT_PLAN":
                default_plan.append(rate)
    print(f"File_name='{file_name}',Plan='{resource_manager_plan}',Num CPUs={num_cpus:2d},rate={rate:.2f}")

print(f"Internal: avg={statistics.mean(internal_plan):8.2f}, sd={statistics.stdev(internal_plan):8.2f}")
print(f"Default:  avg={statistics.mean(default_plan):8.2f}, sd={statistics.stdev(default_plan):8.2f}")

