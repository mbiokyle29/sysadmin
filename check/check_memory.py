#!/usr/bin/env python
"""
check_memory.py
Kyle McChesney

Simple script to check memory useage
and let me know if its going crazy

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
    free_gb = free()

    if int(free_gb) <= 2:
        report(free_gb, args.email)

def free():

    command = ["free","-g"]
    output = subprocess.check_output(command)
    arrayed = [line for line in output.split("\n")]
    
    real_free = arrayed[2].split()[3]
    return real_free

def report(mem, email):

    # Create a text/plain message
    email_body = []
    email_body.append("Hello,\n")
    email_body.append("Warning: only {} GBs of RAM are free".format(mem))

    msg = MIMEText("\n".join(email_body))

    # header stuff
    # no one else cares but me!
    root  = "root@alpha-helix.oncology.wisc.edu"
    subject = "Memory Low Warning ( {}GB )".format(mem)
    
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