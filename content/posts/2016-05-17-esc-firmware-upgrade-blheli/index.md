---
title: ESC Firmware Upgrade (BLHeli)
author: oxi
subtitle: ""
header_img: "img/drone-header.jpg"
comment: false
toc: false
draft: false
lang: de
type: post
date: "2016-05-17"
categories:
  - RC
tags:
  - Deutsch
  - Arduino
  - Nighthawk
  - Quadcopter
  - Tinkering
series: []
---
Als ich [Cleanflight](http://cleanflight.com/) für meine Nighthawk auf die neuste Version aktualisiert hatte, stellte ich fest, dass die Motoren nicht mehr starteten. Nach einer Analyse hatte ich herausgefunden, dass die vorinstallierte Firmware bei den ESC's nicht mehr kompatibel ist mit der aktuellen [OneShot](http://blog.oscarliang.net/oneshot125-esc-quadcopter-fpv/) Implementation in [Cleanflight](http://cleanflight.com/).

![P1020189](img/P1020189.jpg)
Damit ich die Firmware aktualisieren konnte, musste ich zuerst den Schrumpfschlauch entfernen. Nach getaner Arbeit deckte ich die ESC's mit Elektriker-Isolierband wieder ab.

Die [BLHeliSuite](https://blhelisuite.wordpress.com/) hat die Möglichkeit, ein Arduino als Programmer zu benutzen, direkt eingebaut.
![P1020190](img/P1020190.jpg)
Die ESC's werden über drei der vier offen liegenden Kontakte neu beschrieben. Dafür hatte ich eine Wäscheklammer mit 90°-Pin-Headers, Schrumpfschlauch und natürlich Heisskleber umgebaut.

Die Idee für diese Lösung hatte ich vom Video [DIY Flashing Emax 12A Esc with BLHeli](https://www.youtube.com/watch?v=cH-wWne3YVY).

![P1020191](img/P1020191.jpg)
![P1020192](img/P1020192.jpg)
![P1020193](img/P1020193.jpg)
