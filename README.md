# oc.pulseaudio

![Update oc.pulseaudio](https://github.com/abcdesktopio/oc.pulseaudio/workflows/Update%20oc.pulseaudio/badge.svg)
![Docker Stars](https://img.shields.io/docker/stars/abcdesktopio/oc.pulseaudio.svg) 
![Docker Pulls](https://img.shields.io/docker/pulls/abcdesktopio/oc.pulseaudio.svg)


Sound container for abcdesktop
- use pulseaudio


## To get more informations

Please, read the public documentation web site:
* [https://www.abcdesktop.io](https://www.abcdesktop.io)
* [https://abcdesktopio.github.io/](https://abcdesktopio.github.io/)

## Sound service for abcdesktop.io for kubernetes

```
git clone git://github.com/abcdesktopio/oc.pulseaudio
cd oc.pulseaudio
git submodule update --init --recursive --remote
```



### build `oc.pulseaudio` image

```
docker build -t abcdesktopio/oc.pulseaudio:dev .
```


