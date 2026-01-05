"""deals with .lang files"""

import re
from typing import Optional

_CRLF = '\r\n'
_U8BOM = 'utf-8-sig'

class LangFile:
  """holds translatable strings"""

  _WORD = r'[a-z]+'
  _CAPITAL = r'[A-Z][a-z]*'
  _CAMEL = rf'{_WORD}(?:{_CAPITAL})*'
  _SNAKE = rf'{_WORD}(?:_{_WORD})*'
  _ABBR = r'[A-Z]{2,}'
  _PASCAL = rf'(?:{_ABBR}|{_CAPITAL})+'
  _NUM = r'[0-9]+'
  _SUFFIX_OPT = r'[0-9]*'
  _COMPONENT = rf'(?:{_CAMEL}|{_SNAKE}|{_PASCAL}|{_NUM}){_SUFFIX_OPT}'
  _ID = rf'{_COMPONENT}(?:\.{_COMPONENT})*'
  _STR_DEF = re.compile(rf'({_ID})=(.*)')

  def __init__(self):
    self.__data: dict[str, list[str]] = {}

  def load(self, path: str):
    """parse from file"""

    with open(path, 'r', encoding=_U8BOM, newline=_CRLF) as f:
      last_key: Optional[str] = None
      for n, line in enumerate(f):
        line = line.removesuffix(_CRLF)
        if line == '':
          last_key = None
          continue
        m = self._STR_DEF.fullmatch(line)
        if m is None:
          if last_key is None:
            raise ValueError(f'missing key before line {n}')
          self.__data[last_key].append(line)
        else:
          k, v = m.groups()
          self.__data[k] = [v]
          last_key = k

  def save(self, path: str):
    """write into file"""

    with open(path, 'w', encoding=_U8BOM, newline=_CRLF) as f:
      f.writelines('{}={}\n'.format(k, '\n'.join(v)) for k, v in self.__data.items())

if __name__ == '__main__':
  lang = LangFile()
  lang.load('workdir/assets/lang/en_US.lang')
  lang.save('test.lang')
