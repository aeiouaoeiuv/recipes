#!/usr/bin/python3

import os
import argparse
from argparse import RawTextHelpFormatter

COLOR_LIGHT_RED = '\033[38;5;9m'
COLOR_DEFAULT = '\033[39m'

def create_link(src, dst):
    if False == os.path.exists(dst):
        os.symlink(src, dst)
    else:
        if os.path.islink(dst):
            os.remove(dst)
            os.symlink(src, dst)
        else:
            print("Skip " + COLOR_LIGHT_RED + dst + COLOR_DEFAULT + ", because it's not a symlink")

def create_links(adjusted_args):
    os.chdir(adjusted_args['dst'])

    src_list = os.listdir(adjusted_args['src'])
    for name in src_list:
        src_file = os.path.join(adjusted_args['src'] + "/", name)
        dst_file = name
        create_link(src_file, dst_file)

def adjust_args(parser):
    args = parser.parse_args()
    if None == args.src:
        parser.print_help()
        exit(1)

    adjusted_args = {}
    adjusted_args['src'] = args.src
    if None == args.dst:
        adjusted_args['dst'] = os.getcwd()
    else:
        adjusted_args['dst'] = args.dst
    return adjusted_args

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='create soft link to files', formatter_class=RawTextHelpFormatter)
    parser.add_argument('-s', metavar='<source dir>', dest='src', action='store', help='src dir')
    parser.add_argument('-d', metavar='<dest dir>', dest='dst', action='store', help='dst dir, default to current dir')

    adjusted_args = adjust_args(parser)

    create_links(adjusted_args)

