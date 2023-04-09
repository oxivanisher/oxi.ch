---
title: 3D Drucker Statistiken
author: oxi
subtitle: "Mehr als 13'000 Stunden gedruckt o.O"
header_img: "img/3dprinting-header.jpg"
comment: false
toc: false
draft: false
lang: de
type: post
date: "2023-04-09"
categories:
  - 3D Printing
tags:
  - Deutsch
  - 3D Printing
series: []
---
# Einführung
Als anfangs 2023 mein Prusa MK2 nach 7 Jahren in Rente ging, habe ich mich gefragt wie viele Stunden er wohl in seinem "Leben" gedruckt hat. Immerhin ist er als ein original Prusa MK2 "geboren" worden und ist dann alle Aktualisierungen durchgegangen bis zum MK2.5S. Zwar hat der Drucker selbst einen Druckzeit-Zähler, aber dieser wurde entweder erst mit einer späteren Firmware-Version eingeführt oder wurde einmal unabsichtlich gelöscht als ich eine falsche Version auf den Drucker installiert habe.

Ich habe aber fast seit Beginn meiner "3D Druck Karriere" [Octoprint](https://octoprint.org/) mit einem [Webcam Livestream](/3d-printer-livestream/) an allen Druckern und die daraus resultierenden Timelapse-Videos habe ich alle archiviert. Durch das Zählen der Frames in den Videos kann ich somit hoch rechnen wie viele Sekunden jeder Drucker gedruckt hat. Zudem kann ich aus den Dateinamen noch weitere Schlüsse ziehen. Da vor jedem Druck die Druckplatte geheizt wird habe ich mit Durchschnitts-Werten die reine Druckzeit berechnet.

Mit etwas Bash-Magie und Rechenleistung bin ich auf die folgenden Zahlen (Stand 09.04.2023) gekommen:

## Druckaufträge
| | Total|PLA|PETG|FLEX|ASA|ABS|Fehlschläge|
|:----|----:|----:|----:|----:|----:|----:|----:|
|Kossel XL|520|68|88|0|0|0|0|
|Prusa MK2.5|2711|1645|295|86|28|54|194|
|Prusa MK3S+|529|49|34|8|0|0|17|
|Prusa MK3S+ MMU2S|573|460|50|0|0|0|73|
|**Total**|**4333**|**2222**|**467**|**94**|**28**|**54**|**284**|


## Stunden gedruckt
| |Total|Ohne Heizen|
|:----|----:|----:|
|Kossel XL|792|769|
|Prusa MK2.5|7659|7546|
|Prusa MK3S+|2398|2393|
|Prusa MK3S+ MMU2S|2544|2518|
|**Total**|**13393**|**13226**|

Ja ... ich bin auch überrascht wie viele Stunden ich schon gedruckt habe! Ich habe die Zahlen mehrfach Stichprobenartig überprüft und alles scheint so zu stimmen. 😎

### Anmerkungen
* [Kossel XL](/posts/2016-02-02-3d-drucker-bau-review/):
  * Da dies der erste Drucker war, hatte dieser nicht von Anfang an Octoprint und Timelapses. Die Anzahl Drucke und Stunden sind also noch höher als hier angegeben.
  * Zu Beginn hatte der Slicer das Material nicht in die Dateinamen gespeichert. Darum ist die Differenz der Aufträge Total zu Material so gross. Es wurde jedoch fast nur PLA gedruckt.
* Prusa:
  * Der korrekte Name der Drucker beinhaltet jeweils noch ein i3, also z.B. Prusa i3 MK3
  * Prusa MK2 Upgrade Pfad: Prusa MK2 > Prusa MK2S > Prusa MK2.5
  * Prusa MMU2 Upgrade Pfad: Prusa MMU2 > Prusa MMU2S

## Dienstjahre der Drucker

| |Inbetriebnahme|Ausserbetriebnahme|
|:----|:----|:----|
|Kossel XL|Februar 2016|Februar 2017|
|Prusa MK2.5|Dezember 2016|Januar 2023|
|Prusa MK3S+|Februar 2023|-|
|Prusa MK3S+ MMU2S|September 2018|-|
