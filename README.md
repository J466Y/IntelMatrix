# leaky :key:
[![Python 3.5|3.6](https://img.shields.io/badge/python-3.x-green.svg)](https://www.python.org/) 
[![License](https://img.shields.io/badge/license-GPLv3-red.svg)](https://raw.githubusercontent.com/almandin/fuxploider/master/LICENSE.md)

## :star2: Credits
This project is built upon the foundational work of [ACCEIS' LeakScraper](https://github.com/Acceis/leakScraper) and the leak module of [vil's H4X-Tools leak search module](https://github.com/vil/H4X-Tools).
And is a fork of the project [saladandonionrings' Leaky](https://github.com/saladandonionrings/leaky)

## Installation

You can install Leaky and its prerequisites using the following commands:

```bash
# install mongodb
sudo apt-get install gnupg
curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/6.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# start mongodb
sudo systemctl enable mongod
sudo systemctl start mongod
# if failed :
sudo systemctl daemon-reload
sudo systemctl status mongod

# install project
git clone https://github.com/J466Y/IntelMatrix.git
cd IntelMatrix
chmod +x ./install.sh
./install.sh
```

### Usage
### File types supported
- TXT 
  - Stealer Logs (URL:Login:Password)
  - Combos list (Login:Password)
  - Phone numbers
- SQL
- CSV
- JSON

### Importing data

(UI Recommended)
```bash
# change creds for users in init.py
python3 init.py 

# import the file into mongodb
python3 import.py -t {creds,phone,misc} -f <file> -n <leak_name> -d <leak_date>

# start web instance on port 9999 ; default pass -> leaky123
python3 scraper.py
```
### Functionalities
IntelMatrix provides the following capabilities:

* **Search** : As it says.
* **Inventory** : Inventory of your breach files.
* **Upload** : Add your own breach files and API providers.
* **Links** : Useful links for data leaks.
* **Check Hostname** : Check suspicious Hostnames

#### Search
##### Credentials/ULP
![search](https://github.com/user-attachments/assets/63da8750-24da-4c3a-9a58-edea90bee637)

##### Phone
![phones](https://github.com/user-attachments/assets/0e2fa15a-dd32-4b36-9dd2-567dab61d1f7)

##### Misc
![csv](https://github.com/user-attachments/assets/d6a921ee-8409-4bb1-9a41-03209500aa50)

##### Leak Search

![leaksearch](google.es)

#### Inventory
![list](https://github.com/user-attachments/assets/cf8612b3-6215-49c9-8f0d-19c56f1b2c27)

#### Upload
![upload](https://github.com/user-attachments/assets/ae9f33e9-f35f-4443-886c-f85a8e1d9558)

#### Links
![links](https://github.com/user-attachments/assets/0ffc22c2-70b6-47d3-890a-bbd694106579)

#### Hostname Checker
![hostname](google.es)
