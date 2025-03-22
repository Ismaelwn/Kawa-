import subprocess
import os

def cmd2string(cmd, check_message=None):
    check = (check_message is not None)

    try:
        res = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=check)
    except subprocess.CalledProcessError as e:
        raise ValueError(check_message + "\n" + e.stderr)

    if res.stdout:
        print("OUTPUT : \n" + res.stdout, end='')

    if res.stderr:
        print(f"ERROR pendant \033[1m{cmd}\033[0m : \n{res.stderr[:-1]}", end='')

if os.path.exists("tests"):
    fichiers = os.listdir("tests")
else:
    raise FileNotFoundError("Les archives 'kwa' doivent se trouver dans un répertoire 'tests' à la racine du fichier")

cmd2string("dune build", check_message="Compilation impossible")

print("Projet compilé avec succès")
print("--------------------------")

# Filtrer les fichiers pour ne prendre en compte que ceux avec l'extension .kwa
fichiers_kwa = [f for f in fichiers if f.endswith('.kwa')]

for fichier in fichiers_kwa:
    print(f"fichier : {fichier}")
    cmd2string(f"./kawai.exe tests/{fichier}")
