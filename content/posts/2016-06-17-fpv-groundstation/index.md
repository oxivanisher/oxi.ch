---
title: FPV Groundstation
author: oxi
subtitle: ""
header_img: "img/drone-header.jpg"
comment: false
toc: false
draft: false
lang: de
type: post
date: "2016-06-17"
categories:
  - RC
  - 3D Printing
tags:
  - Deutsch
  - 3D Printing
  - 3D Design
  - FPV
  - Quadcopter
series: []
---
![DSC_0277](img/DSC_0277.jpg)
Um auch mit den in der <a href="https://rc.oxi.ch/index.php/Wichtige_Links" target="_blank">Schweiz legalen 25mw Video Sendern</a> möglichst störungsfrei fliegen zu können, habe ich mir eine FPV Groundstation gebaut. Gleichzeitig habe ich die Aufnahme des Streams in eine Datei ermöglicht.

Die Grounstation besteht aus einem <a href="http://www.banggood.com/ImmersionRC-FPV-DUO5800-V4_1-Race-Edition-40ch-5_8GHz-Raceband-Dual-Output-AV-Receiver-p-1020631.html" target="_blank">ImmersionRC FPV DUO5800</a> mit zwei Antennen. Durch die Diversity-Schaltung nimmt der Empfänger immer das stärkere der beiden Antennen-Signale und stellt somit das best mögliche Bild sicher.

![DSC_0275](img/DSC_0275.jpg)
Die verwendeten Antennen sind <a href="http://ImmersionRC 5.8GHz SpiroNet 8dBi RHCP Mini Patch" target="_blank">ImmersionRC 5.8GHz SpiroNet 8dBi RHCP Mini Patch</a> und <a href="http://fpvracing.ch/de/fpv-zubehor/113-immersionrc-58ghz-spironet-antenna-v2-set-sma.html" target="_blank">ImmersionRC 5.8GHz SpiroNet RHCP Antenne V2</a>. Die Patch Antenne deckt einen 45° Bereich ab und wird in die Flugrichtung ausgerichtet. Falls aus diesem Bereich raus geflogen wird, wechselt das Signal zur &#8220;normalen Cloverleaf&#8221; Antenne, welche einen 360° Bereich abdeckt. Der 45° Bereich ermöglicht eine grössere Distanz zum Ausgangspunkt, wobei die 360° vor allem beim Starten und Landen zum tragen kommt.

Der Empfänger hat zudem zwei Video-Ausgänge, welche ich brauche um meine <a href="http://www.hobbyking.com/hobbyking/store/__28342__FatShark_PredatorV2_RTF_FPV_Headset_System_w_Camera_and_5_8G_TX.html" target="_blank">FatShark PredatorV2</a> mit dem Bild zu versorgen und gleichzeitig den Stream auf einem Linux Laptop anzuzeigen (und auch zu speichern). Weitere Details dazu wie ich das umgesetzt habe, sind auf meiner <a href="https://rc.oxi.ch/index.php/Benutzer:Oxi/FPV_Setup" target="_blank">RC Wiki Seite</a> zu finden.

![Immersion-Duo-5800V4-Mount-Immersion-Case.png](img/Immersion-Duo-5800V4-Mount-Immersion-Case.png)
Damit der DUO5800 auf dem Stativ montiert werden kann, habe ich in <a href="http://onshape.com" target="_blank">onshape</a> eine Halterung entworfen. Diese wurde anschliessend auf meinem 3D Drucker produziert und verrichtet gute Dienste. Die .STL Dateien können von meiner <a href="https://oxi.ch/3dobjects" target="_blank">3D Objekte</a> Website aus dem Ordner &#8220;RC FPV&#8221; heruntergeladen werden.

Am Schluss, habe ich noch ein zusätzliches Strom-Kabel vom Akku der Groundstation zur FatShark hinzugefügt. So muss ich nicht mehr die unpraktische Batterie am Kopf tragen und habe auch eine bessere Übersicht wann die FPV Batterien geladen werden muss.
