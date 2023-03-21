---
title: QAV-Skitzo follow-up
author: oxi
subtitle: "(endlich!) – 6 Monate im Leben eines Quadcopters"
header_img: "img/drone-header.jpg"
comment: false
toc: false
draft: false
lang: de
type: post
date: "2017-11-22"
categories:
  - RC
tags:
  - Deutsch
  - 3D Printing
  - 3D Design
  - FPV
  - Quadcopter
  - QAV-Skitzo
  - Quadcopter
series: []
---
Da ich nie so richtig zufrieden war mit meinen Upgrades welche ich an meinem Haupt-Copter QAV-Skitzo gemacht hatte, hat die Produktion dieses Follow-Up Videos viel länger gedauert als ich eigentlich wollte.

Folgende Stationen habe ich in den letzten sechs Monaten durchlaufen:

* Upgrade des Flugcontrollers von Omnibus F3 auf den Omnibus F4 SD da der Voltage Sensor nicht mit den LiHV Akkus zurecht kam. Leider habe ich ungewollt einen Klon gekauft bei [Elektromodelle](https://www.elektromodelle.ch/). Passt auf, dieser wurde als "the real deal" verkauft! Durch dieses Upgrade war war ein XSR Telemetrie-Hack und Current Sensor Anpassungen nötig.
* [Protektoren für die Arme (inc. start Pads) designed.](https://www.thingiverse.com/thing:2533522)
* Diverse [FPV Cam-Mounts](https://www.thingiverse.com/thing:2300321) durchprobiert und erstellt.
* [OpenTX auf der FrSky Taranis auf Version 2.2 aktualisiert.](https://www.youtube.com/watch?v=Wo3vI181JJk)
* Betaflight über fast alle RC-Versionen bis auf 3.2.2 aktualisiert.
* Die [LUA-Scripts](https://github.com/betaflight/betaflight-tx-lua-scripts) auf der Taranis konfiguriert und auch die "neuen" schon fast von Anfang an mitgetestet.
* RGB LED-Streifen montiert und soweit konfiguriert dass die Farbe sich der Video-Frequenz anpasst. Dieses Betaflight feature wurde [von mir vorgeschlagen](https://github.com/betaflight/betaflight/issues/3228) - yay OpenSource!
* Festgestellt das beim Wechsel vom Omnibus F4 auf das Omnibus F4 SD Target die Orientierung um 90° gedreht werden musste. Dies hatte ich bei diesem [YouTube Video](https://www.youtube.com/watch?v=HeUdL9BuC0E) festgestellt, da der Copter spontan einen Break-Dance hingelegt hat. 😀
* Das RSSI-Signal auf Kanal 16 gelegt und somit endlich wieder RSSI Informationen auf dem OSD angezeigt bekommen.
* Blackbox auf "immer aufnehmen" konfiguriert.
* Da ich immer wieder [Vibrationen in den HD-Videos](https://www.youtube.com/watch?v=8RXnCdMQDZA) hatte, habe ich alle möglichen Kombinationen von Motor- und FC-Soft-Mounts sowie Kamera Mounts aus unterschiedlichen Flex-Materialien und Wandstärken ausprobiert. Schlussendlich waren die Kugellager der Motoren das Hauptproblem…
* Auf Crossfire Micro TX/RX umgestiegen.
* Etwas OT: Die Fatshark HD2 Firmware aktualisiert, damit auch der DVR immer automatisch aufnimmt

Nach all diesen (und wohl noch mehr) Änderungen hatte der FC überraschend zwischen zwei Akkus einen Defekt erlitten (wohl in der Stromversorgung) und ist seit da per USB nicht mehr erreichbar. Auch sind die gemessenen Volts des Voltage Sensors der Batterie komplett daneben (27 anstatt 16.8). Also musste ich den FC wechseln und habe die Chance auch gerade genutzt, um die ESCs auszutauschen. Da ich ein Fan von Betaflight bin,  habe ich den BF F4 und die BlHeli_S 32 von Betaflight verbaut um das Projekt ein bisschen zu unterstützen.

Genaueres (auch mit vielen Flugaufnahmen) seht ihr im folgenden Video:
{{< youtube x0Nq8D2o9gU >}}
