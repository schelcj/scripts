#!/usr/bin/env python

import argparse
import os

class WallPaper(object):
  def __init__(self):
    self._prefix           = os.getenv('HOME') + '/.wallpapers2/'
    self._lock             = self._prefix + 'lock'
    self._hist             = self._prefix + 'history.db'
    self._category         = self._prefix + 'category'
    self._wallpaper_dir    = self._prefix + 'Wallpapers'
    self._current          = self._prefix + 'current'
    self._resolution       = self._prefix + 'resolution'
    self._log              = self._prefix + 'log'
    self._sources          = self._prefix + 'sources'
    self._bgsetter         = 'fbsetbg -a'
    self._default_category = 'all'

    self.category   = self._get_category()
    self.resolution = self._get_resolution()
    self.sources    = self._get_source_dirs()
    self.wallpapers = self._get_wallpapers()

  def __process_args(self):
    if self.args.dump_cache:
      self.dump_cache()
      exit()

    elif self.args.flush_cache:
      self.flush_cache()
      exit()

    elif self.args.clear:
      self.clear()

    elif self.args.unlock:
      self.unlock()
      exit()

    elif self.args.lock:
      self.lock()
      exit()

    elif self.is_locked and not self.args.unlock:
      print "currently locked, bailing out"
      exit()

    elif self.args.previous:
      self.set_previous()
      exit()

  def _get_category(self):
    category = self._default_category

    if self.args.category:
      category = self.args.category
    elif os.path.exists(self._category):
      category = file(self._category).read()

    return category

  def _get_resolution(self):
    resolution = ''

    if self.args.resolution:
      resolution = self.args.resolution
    elif os.path.exists(self._resolution):
      resolution = file(self._resolution).read()

    return resolution


  def _get_source_dirs(self):
    dirs = []

    if self.category == 'all':
      for source in file(self._sources).read():
        dirs.append(self._wallpaper_dir + '/' + source)

    else

    return dirs

  def _get_wallpapers(self):
    wallpapers = []

    for source in self.sources:
      for root, dirs, files in os.walk(source):
        for file in files
          wallpapers.append(os.path.join(root,file))

    return wallpapers

  def parse_args(self):
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
    self.__process_args()

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

if __name__ == '__main__':
  wallpaper = WallPaper()
  wallpaper.parse_args()
  wallpaper.set_wallpaper()
