---
title: 3D Drucker Statistiken
author: oxi
subtitle: "Mehr als 11'000 Stunden gedruckt o.O"
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
Als anfangs 2023 mein Prusa MK2 nach 7 Jahren in Rente ging, habe ich mich gefragt wie viele Stunden er wohl in seinem "Leben" gedruckt hat. Immerhin ist er als ein original Prusa MK2 "geboren" worden und ist dann alle Aktualisierungen durchgegangen bis zum MK2.5S. Zwar hat der Drucker selbst einen Druckzeit-Zähler, aber dieser wurde entweder erst mit einer späteren Firmware-Version eingeführt oder wurde einmal unabsichtlich gelöscht als ich eine falsche Version auf den Drucker installiert habe.

Ich habe aber fast seit Beginn meiner "3D Druck Karriere" [Octoprint](https://octoprint.org/) mit einem Webcam Livestream an allen Druckern und die daraus resultierenden Timelapse-Videos habe ich alle archiviert. Durch das Zählen der Frames in den Videos kann ich somit hoch rechnen wie viele Sekunden jeder Drucker gedruckt hat. Zudem kann ich aus den Dateinamen noch weitere Schlüsse ziehen. Da vor jedem Druck die Druckplatte geheizt wird habe ich mit Durchschnitts-Werten die reine Druckzeit berechnet.

Mit etwas Bash-Magie und Rechenleistung bin ich auf die folgenden Zahlen gekommen:

| |Druckaufträge Total|PLA|PETG|FLEX|ASA|ABS|Fehlschläge|Stunden Total|Stunden ohne Heizen|
|:----|:----|:----|:----|:----|:----|:----|:----|:----|:----|
|Kossel XL|520|68|88|0|0|0|0|792|769|
|Prusa MK2|2711|1645|295|86|28|54|194|7659|7546|
|Prusa MK3|529|49|34|8|0|0|17|2398|2393|
|Prusa MK3 MMU2|92|429|37|0|0|0|56|392|368|
|Total|3852|2191|454|94|28|54|267|11241|11076|

Ja ... ich bin auch überrascht wie viele Stunden ich schon gedruckt habe! Ich habe die Zahlen mehrfach Stichprobenartig überprüft und alles scheint so zu stimmen. 😎

Ein paar Anmerkungen zum Kossel XL:
* Da dies der erste Drucker war, hatte dieser nicht von Anfang an Octoprint und Timelapses. Die Anzahl Drucke und Stunden sind also noch höher als hier angegeben.
* Zu Beginn hatte der Slicer das Material nicht in die Dateinamen gespeichert. Darum ist die Differenz der Aufträge Total zu Material so gross. Es wurde jedoch fast nur PLA gedruckt.
