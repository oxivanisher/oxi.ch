---
title: "Babylon 5: Starfury - Bust"
author: oxi
subtitle: "It's bad luck to die on empty stomach. - G'Kar to Londo"
header_img: "img/minipainting-header.jpg"
comment: false
toc: false
draft: false
lang: de
type: post
date: "2023-04-10"
categories:
  - Miniatures
tags:
  - Deutsch
  - 3D Printing
  - 3D Design
  - Prusa
  - Diorama
  - Tinkering
  - CNC
  - Mini Painting
images:
  - ./thumbnail.jpg
  - ./thumbnail1.jpg
  - ./thumbnail2.jpg
  - ./thumbnail3.jpg
  - ./thumbnail4.jpg
  - ./thumbnail5.jpg
series: []
---
Als grosser Fan der Serie Babylon 5 hat mich das [Modell der Starfury auf Gambody](http://gambody.com/3d-models/starfury) natürlich angesprochen und nach 13 Tagen reine Druckzeit mit dem Prusa i3 MK3S+ waren alle Teile fertiggestellt. Ausnahmsweise habe ich mich gegen den SLA- und für den FDM-Druck entschieden. Das Modell ist dadurch viel grösser (45 cm x 35 cm x 30 cm) als alles was ich bis jetzt gemacht habe, aber natürlich ist die Druckqualität nicht auf dem Level eines SLA-Druckes.

{{< image-gallery gallery_dir="1" >}}

Eigentlich wollte ich das ganze Raumschiff einfach in silber farbigem Filament drucken und nicht weiter bemalen. Leider brauchte aber der Druck mehr als die ganze Rolle (1 Kg !) Filament und von diesem Silber hatte ich nur diese eine. Also habe ich dann das ganze Modell mit Citadel Leadbelcher aus der Spraydose bemalt. Einzelne Details wie die Waffen, das [Earth Alliance](https://babylon5.fandom.com/wiki/Earth_Alliance) Logo und das Cockpit habe ich mit normal Miniature-Painting-Farben bemalt.

{{< image-gallery gallery_dir="2" >}}

Das Modell ist zwar für LED-Beleuchtung vorbereitet, aber simple LEDs mit nur einer Farbe sind für mich nicht genug. Ich verwende auch hier WS2812 RGB-LEDs welche mit [WLED](https://kno.wled.ge) individuell angesteuert werden können. Diese Erweiterung erfordert aber zusätzliche Aufwände:
* Elektronik mit WLED auf einem WeMos D1 mini ESP8266 und Logic level shifter
* Kabelbaum der das Signal durch alle LEDs schleust da diese in Serie verkabelt werden müssen
* 3D-Designete Einsatz um die vier LEDs pro Triebwerk zu befestigen

{{< image-gallery gallery_dir="3" >}}

Die Scheiben im Cockpit wären vorgesehen um sie mit klarem Filament zu drucken. Dies ist zwar eine schöne Idee, aber die Teile die daraus resultieren, sind nicht komplett transparent. Es gibt Möglichkeiten diese zu Drucken, dann zu schleifen und polieren, aber ich habe mich dafür entschieden Plexiglas auf meinem Mini CNC aus zuschneiden. Dies hatte ich noch nie gemacht und es hat einige Zeit gebraucht bis ich funktionierende Einstellungen für das CAM von Fusion 360 hatte. Das Resultat ist aber für das erste Mal ganz akzeptabel herausgekommen. Genau so wie die LEDs im Cockpit habe ich dann die Scheiben mit UV-Resin-Kleber eingeklebt.

{{< image-gallery gallery_dir="4" >}}

Als [WLED Effekte](https://kno.wled.ge/features/effects/
) für die LEDs habe ich folgendes eingestellt:
* Die Triebwerke gehen zufällig an und aus um Kurs-Korrekturen zu simulieren ([Effekt #18](https://kno.wled.ge/features/effects/)).
* Die Cockpit-Innenbeleuchtung wechselt langsam zwischen rot und orange ([Effekt #2](https://kno.wled.ge/features/effects/)).

Ich schätze den Arbeitsaufwand (exklusiv 3D-Druck) auf ca. 20 Stunden.

{{< image-gallery gallery_dir="5" >}}

Die Starfury wurde am 9. April 2023 fertiggestellt.
