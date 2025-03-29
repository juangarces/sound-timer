# Sound Timer
Plays a voice notification every 1, 5, 15, 30 and 60 minutes in your terminal. A simple bash script for linux.

## Usage scenarios
* In day trading, if you want to be notified every time a new candle/bar is confirmed in the most commonly used timeframes.

* When you want to set up an exercise routine with a specific duration and receive voice notifications.

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
To get a voice notification every 1, 5, 15, 30 and 60 minutes run this new command in your terminal:
```sh
stimer start
```
Select time intervals. Example to get voice notification every 5 and 15 minutes:
```sh
stimer start 5 15
```
To get notification 10 seconds before time interval.
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
* Add more useful information with the status.
* Add more voices.
* Add translations.