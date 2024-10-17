import shutil
from os import listdir
from os.path import isfile, join

path = "Interface/Translations"
f_english = [f for f in listdir(path) if isfile(join(path, f)) and f.endswith("ENGLISH.txt")]

if len(f_english) < 1:
  print("Missing Translation_ENGLISH.txt in directory")
  exit()

f_raw = f_english[0].replace("ENGLISH.txt", "")

languages = [
  "CHINESE",
  "CZECH",
  "DANISH",
  # "ENGLISH",
  "FINNISH",
  "FRENCH",
  "GERMAN",
  "GREEK",
  "ITALIAN",
  "JAPANESE",
  "NORWEGIAN",
  "POLISH",
  # "RUSSIAN",
  "SPANISH",
  "SWEDISH",
  "TURKISH"
]

en_path = join(path, f_english[0])
for l in languages:
  new_path = join(path, f_raw + l + ".txt")
  shutil.copyfile(en_path, new_path)

print("Done")
