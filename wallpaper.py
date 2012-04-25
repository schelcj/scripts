#!/usr/bin/env python

import argparse
import os
import random

class WallPaper(object):
  def __init__(self):
    self._prefix             = os.path.join(os.getenv('HOME'), '.wallpapers')
    self._lock               = os.path.join(self._prefix, 'lock')
    self._hist               = os.path.join(self._prefix, 'history.db')
    self._category           = os.path.join(self._prefix, 'category')
    self._wallpaper_dir      = os.path.join(self._prefix, 'Wallpapers')
    self._current            = os.path.join(self._prefix, 'current')
    self._resolution         = os.path.join(self._prefix, 'resolution')
    self._log                = os.path.join(self._prefix, 'log')
    self._sources            = os.path.join(self._prefix, 'sources')
    self._bgsetter           = 'fbsetbg -a'
    self._default_category   = 'all'
    self._default_resolution = ''
    self.sources             = []
    self.wallpapers          = []

    self._parse_args()
    self._build_categories()
    self._build_resolution()
    self._build_source_dirs()
    self._build_wallpapers()

  def _build_categories(self):
    if self.args.category:
      self.category = self.args.category

    elif os.path.exists(self._category):
      self.category = file(self._category).read()

    else:
      self.category = self._default_category

    if self.category != self._default_category:
      with open(self._category, 'w') as f:
        f.write(self.category)

  def _build_resolution(self):
    if self.args.resolution:
      self.resolution = self.args.resolution

    elif os.path.exists(self._resolution):
      self.resolution = file(self._resolution).read()

    else:
      self.resolution = self._default_resolution

    if self.resolution != self._default_resolution:
      with open(self._resolution, 'w') as f:
        f.write(self.resolution)

  def _build_source_dirs(self):
    if self.category == self._default_category:
      for source in file(self._sources).readlines():
        self.sources.append(os.path.join(self._wallpaper_dir,source.rstrip()))

    else:
      self.sources.append(os.path.join(self._wallpaper_dir,self.category))

  def _build_wallpapers(self):
    for source in self.sources:
      for root, dirs, files in os.walk(source):
        for file in files:
          self.wallpapers.append(os.path.join(root,file))

  def _parse_args(self):
    parser = argparse.ArgumentParser(description='Wallpaper changer thingus')

    parser.add_argument('-c',
        '--category',
        help='Wallpaper Category',
        action='store_true')

    parser.add_argument('-r',
        '--resolution',
        help='Wallpaper resolution',
        action='store_true')

    parser.add_argument('-d',
        '--dump-cache',
        help='Display wallpaper cache',
        action='store_true')

    parser.add_argument('-f',
        '--flush-cache',
        help='Flush the wallpaper cache',
        action='store_true')

    parser.add_argument('-l',
        '--lock',
        help='Lock the current wallpaper',
        action='store_true')
    
    parser.add_argument('-u',
        '--unlock',
        help='Unlock the curent wallpaper',
        action='store_true')

    parser.add_argument('-C',
        '--clear',
        help='Clear previous category and resolution',
        action='store_true')

    parser.add_argument('-p',
        '--previous',
        help='Set wallpaper to the previous wallpaper',
        action='store_true')

    self.args = parser.parse_args()

  def _set_wallpaper(self, paper):
    print paper
  
  def _get_random_wallpaper(self):
    return random.choice(self.wallpapers)

  def lock(self):
    f = open(self._lock,'w')
    f.close()

  def unlock(self):
    if self.is_locked():
      os.remove(self._lock)

  def is_locked(self):
    return os.path.exists(self._lock)

  def set_previous(self):
    print "set_previous(self)"

  def clear(self):
    print "clear(self)"

  def flush_cache(self):
    print "flush_cache(self)"

  def dump_cache(self):
    print "dump_cache(self)"

  def set_wallpaper(self):
    if len(self.wallpapers) == 1:
      _set_wallpaper(self.wallpapers[0])


if __name__ == '__main__':
  wallpaper = WallPaper()

  if wallpaper.args.dump_cache:
    wallpaper.dump_cache()

  elif wallpaper.args.flush_cache:
    wallpaper.flush_cache()

  elif wallpaper.args.clear:
    wallpaper.clear()

  elif wallpaper.args.unlock:
    wallpaper.unlock()

  elif wallpaper.args.lock:
    wallpaper.lock()

  elif wallpaper.is_locked() and not wallpaper.args.unlock:
    print "currently locked, bailing out"

  elif wallpaper.args.previous:
    wallpaper.set_previous()

  else:
    #wallpaper.set_wallpaper()
    print wallpaper.wallpapers


