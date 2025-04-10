# Sound Timer
Plays a voice notification every 1, 5, 15, 30, 60 minutes and every 4 hours. It follows the clock, so notifications happen at the next matching time—like 14:15, 14:30, or 16:00—depending on the interval you choose. Uses your system’s timezone or one you set. A simple Bash script for Linux.

## Usage scenarios
* In day trading, if you want to be notified every time a new candle/bar is confirmed in the most commonly used timeframes.
* When you want to set up a workout routine with a specific duration and receive voice notifications.

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
To get a voice notification every 1, 5, 15, 30, 60 minutes and every 4 hours run this new command in your terminal:
```sh
stimer start
```
Select time intervals. Example to get voice notification every 15 minutes and every 4 hours following the New York timezone:
```sh
stimer start 15 4h -tz=newyork
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
* Fix issue: Once script is running it has to be stopped to change options.
* Add more useful information with the status.
* Add more voices.
* Add translations.