#!/usr/bin/env python
"""
check_storage.py
Kyle McChesney

Simple script to check disk useage and email me if full!

"""

import logging, argparse, os, subprocess
import smtplib
from email.mime.text import MIMEText
    
def main():
    # args
    parser = argparse.ArgumentParser(
        description = (" Simple script to check disk space useage"),
    )

    parser.add_argument("--email", default="mbio.kyle@gmail.com")
    args = parser.parse_args()

    res = df()

    for dev in res:
        percent = int(res[dev][:-1])

        if percent > 90:
            report(dev, percent, args.email)

def df():

    # hard coded here but whatever
    command = ["df", "-h"]
    output = subprocess.check_output(command)
    arrayed = [line for line in output.split("\n")]
    
    # kill the header
    arrayed.pop()

    check = ['/dev/sdb6','/dev/sdb1']
    res = {}

    for line in arrayed:
        tab_split = line.split()
        if tab_split[0] in check:
            res[tab_split[0]] = tab_split[4]

    return res


def report(dev, percent, email):

    # Create a text/plain message
    email_body = []
    email_body.append("Hello, Kyle\n")
    email_body.append("device: {} is almost full at {}".format(dev,str(percent)))

    msg = MIMEText("\n".join(email_body))

    # header stuff
    # no one else cares but me!
    root  = "root@alpha-helix.oncology.wisc.edu"
    subject = "Disk Check Warning: {}".format(dev)
    
    msg['Subject'] = subject
    msg['From'] = root
    msg['To'] = email
    
    # Send the message via our own SMTP server, but don't include the
    # envelope header.
    s = smtplib.SMTP('localhost')
    s.sendmail(root, [email], msg.as_string())
    s.quit()

if __name__ == "__main__":
    main()