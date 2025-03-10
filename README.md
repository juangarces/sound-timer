# Sound Timer
Plays a voice notification every 1, 5 and 15 minutes in your terminal. A simple bash script for linux.

## Installation
Download the repository or clone it using git:
```sh
git clone https://github.com/juangarces/sound-timer.git
```
Run installation script inside directory:
```sh
./install.sh
```
That's it!

## Usage
To get a voice notification every 1, 5 and 15 minutes run this new command in your terminal:
```sh
stimer start
```
Select time intervals. Example to get voice notification every 5 and 15 minutes:
```sh
stimer start 5 15
```
To get notification x seconds before time interval.
```sh
stimer start -a=10
```
To stop script:
```sh
stimer stop
```
To check the script's status:
```sh
stimer status
```

## TODO
* Add translations.