#!/usr/bin/env python

import argparse

from lang_file import LangFile

ap = argparse.ArgumentParser()

ap.add_argument('LANG_FILE', nargs='+', help='input to read')
ap.add_argument('--output', '-o', help='output path', required=True)

args = ap.parse_args()

lang = LangFile()

for path in args.LANG_FILE:
  lang.load(path)

lang.save(args.output)
