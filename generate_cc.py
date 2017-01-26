#!/bin/python

import argparse
import requests

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate cloud-config file \
    for standalone kubernetes')
    parser.add_argument('local_ip', type=str)
    parser.add_argument('cloud_config_template', type=str)
    parser.add_argument('cloud_config_output', type=str)
    args = parser.parse_args()
    # read template

    with open(args.cloud_config_template) as f:
        template = f.read()
    etcd_url = requests.get("https://discovery.etcd.io/new?size=1").text
    result = template.format(local_ip = args.local_ip, 
                            etcd_discovery_url = etcd_url)
   
    with open(args.cloud_config_output, 'w') as f:
        f.write(result)
    pass
    
