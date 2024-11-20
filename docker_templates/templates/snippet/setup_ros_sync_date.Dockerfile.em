@{
import json
import urllib.request
 
# Define the URL
url = f"http://api.github.com/repos/ros/rosdistro/git/matching-refs/tags/{ros_distro}"
 
# Fetch the data
with urllib.request.urlopen(url) as response:
    data = json.loads(response.read().decode())
 
# Sort the entries by the "ref" value
sorted_data = sorted(data, key=lambda x: x['ref'])

ros_sync_date = sorted_data[-1]['ref'].split('/')[-1]
}@
ENV ROSDISTRO_PKGS_SYNC_DATE=@(ros_sync_date)@
