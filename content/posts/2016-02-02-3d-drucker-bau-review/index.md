---
title: 3D Drucker – Bau review
author: oxi
subtitle: ""
header_img: "img/3dprinting-header.jpg"
comment: false
toc: true
draft: false
lang: de
type: post
date: "2016-02-01"
categories:
  - 3D Printing
tags:
  - 3D Printing
  - Deutsch
  - Arduino
  - Kossel
  - Octoprint
  - RepRap
  - Tinkering
  - Tips
series: []
---
In den letzten zwei Wochen habe ich mir einen Kossel XL von [AliExpress](http://de.aliexpress.com/wholesale?SearchText=kossel+xl) zusammengebaut und in Betrieb genommen. Obwohl ein paar Probleme dabei auftraten, war das Ganze grundsätzlich relativ einfach vonstatten gegangen.

Ich habe versucht, alles was ich so gelernt habe, in unserem [RC Wiki](https://rc.oxi.ch/index.php/Kategorie:3D_Drucker) zu dokumentieren. Natürlich werde ich dieses auch in Zukunft weiter mit Wissenswertem abfüllen.

![Kossel XL Gesammtansicht](img/DSC_0005.jpg)

### Bestellung und Lieferung

Als neuer [AliExpress](http://de.aliexpress.com/wholesale?SearchText=kossel+xl) Kunde war ich dem chinesischen Online Store natürlich auch kritisch gegenüber eingestellt. Vorallem bei Bestellungen ab einem gewissen Wert (ca. 450 Franken). Man hört ja alles mögliche… Komplett zu unrecht nach meinen Erfahrungen! Die Qualität hatte 2-3 Mängel. Aber wenn man den Preis berücksichtigt – man würde in der Schweiz wohl das Fünffache dafür ausgeben – ist das immer noch sehr gut. [AliExpress](http://de.aliexpress.com/wholesale?SearchText=kossel+xl) ist ein Webportal wie [Amazon](https://www.amazon.de), in welchem diverse Shops ihre Waren anbieten. Die Mitarbeiter aus dem [Store “shengshi”](http://de.aliexpress.com/store/1800400), in welchem ich meinen Kossel XL gekauft habe, waren super freundlich und zuvorkommend. Alle meine Fragen wurden innerhalb 24 Stunden beantwortet und als ich ihnen mitgeteilt hatte, dass mein Heated-Bed Probleme macht, schickten sie mir kurzerhand einfach das neuere Modell. Komplett kostenlos versteht sich. Das unglaublichste war für mich jedoch, dass ich nach der Bestellung nur 6 Tage (!) auf die Lieferung des Druckers per DHL warten musste. 25 Franken Lieferkosten von 1.5 kg aus China in die Schweiz mit 6 Tagen Dauer ist unschlagbar!
### Denkfehler und technische Mängel

Die folgenden Probleme hatten mich leider teilweise viel Zeit gekostet. Somit brauchte ich ca. fünf Abende statt einen, um den Kossel XL in Betrieb zu nehmen. Nicht alle Probleme waren jedoch auf die China-Qualität zurückzuführen und hätten mit einer besseren Methodik meinerseits viel weniger Zeit in Anspruch genommen:

* Hätte ich die SD Karte, welche verschweisst und ohne Kommentar mitgeliefert wurde, auch nur einmal in einen PC gesteckt, hätte ich mir sehr, sehr viel “trial & error” sparen können: Auf dieser befand sich eine komplette Bau-Anleitung (inkl. Videos). Ich hatte stattdessen YouTube build Videos geschaut, die aber nicht explizit für meinen Drucker waren. Auch waren jegliche Files, auf welche ich später noch eingehen werde, für die [Marlin Firmware](https://github.com/MarlinFirmware/Marlin) auf der SD vorhanden. Sogar Anleitungen zum besseren Kalibrieren sowie diverse Applikationen wären vorhanden gewesen.
* Bei den Endstops waren die Stecker falsch gecrimpt. Sie machten keinen Kontakt. Die Stecker wurden sicher nicht vom Shop selbst hergestellt, stellt aber ein klarer Qualitätsmangel dar. Hätte ich diese beim ersten Einbauen kurz getestet, hätte ich mir auch da viel Zeit sparen können, da ich als Neuling zuerst stundenlang in der [Marlin Firmware](https://github.com/MarlinFirmware/Marlin) nach Konfigurationsfehlern gesucht hatte.
* Das mitgelieferte Heated-Bed verbrannte zu viel Strom. Dies ist ein Fehler, der dem [Shop](http://de.aliexpress.com/store/1800400) inzwischen bewusst ist. Deswegen werden heute andere Heated-Bed mit dem Drucker verschickt. Sobald das Neue angekommen ist und ich es eingebaut habe, werde ich schauen, ob es auch wirklich besser funktioniert. Das “alte” glasige mit aufgeklebtem Heizpad braucht 300 W (was zu viel ist für das [RAMPS](http://reprap.org/wiki/RAMPS_1.4) board). Das “neue” (Aluminium mit integriertem Heizelement) soll 120 W brauchen. Ich habe schon mehrfach den [Magic Smoke](https://de.wikipedia.org/wiki/Magic_Smoke) erlebt und [MOSFETs](https://de.wikipedia.org/wiki/Metall-Oxid-Halbleiter-Feldeffekttransistor) verbrannt, weil ich das Heated-Bed ausreizen wollte und “rum gespielt” habe. Glücklicherweise sind die [MOSFETs](https://de.wikipedia.org/wiki/Metall-Oxid-Halbleiter-Feldeffekttransistor) mehr oder weniger eine Sollbruchstelle (welche vorher noch mit einer Sicherung geschützt wären, würde man diese nicht zurücksetzen) und man kann diese relativ einfach selbst ersetzen. Vorausgesetzt man kann ein wenig mit dem Lötkolben umgehen. Ein entsprechender [MOSFET](https://de.wikipedia.org/wiki/Metall-Oxid-Halbleiter-Feldeffekttransistor) kostet bei [farnell.com](http://farnell.com/) ca. 2.50 Franken.
* Leider war keine Filament-Spulenhalterung dabei. Dies war aber dann mein erstes, richtiges Druckprojekt. Ich habe die super coolen [Gears](http://www.thingiverse.com/thing:454808) und die verlängerten Halter für den Kossel XL von [Thingiverse](https://www.thingiverse.com) heruntergeladen, drucken und montieren können.

![Kossel XL Filament Spule](img/DSC_0015.jpg)

### Kalibrierung

Zum Kalibrieren habe ich einige [Calibration Cubes](http://www.thingiverse.com/thing:170922) und [Calibration Cube Steps](http://www.thingiverse.com/thing:24238) ausgedruckt. Sobald diese ungefähr den richtigen Massen entsprachen, habe ich ein [Benchy](http://www.thingiverse.com/thing:763622) ausgedruckt und war positiv überrascht wie gut es funktioniert hatte. Lediglich mit Warping hatte ich Probleme. Diese könnten/sollten sich mit dem neuen Heated-Bed lösen. Eine detaillierte Anleitung, was bei der [Kalibrierung](https://rc.oxi.ch/index.php/G-Code#Tips_und_Tricks) zu tun ist, habe ich im Wiki hinterlegt.

### Marlin Firmware v1.0

Die mitgelieferte Firmware war Marlin 1.0. Diese ist inzwischen leider über ein Jahr alt. Das Tolle bei Opensource Software ist jedoch, dass ich nach dem Übernehmen der Parameter in die Konfiguration ganz einfach auf die aktuellen Version 1.1.0-RC3 updaten konnte. Ich habe dem Projekt ein [Issue](https://github.com/MarlinFirmware/Marlin/issues/2932) erstellt, damit meine Beispielkonfiguration in [Marlin](https://github.com/MarlinFirmware/Marlin) integriert werden könnte. Ich werde diese aber so oder so offenlegen, sobald ich damit zufrieden bin.

### Aktuelle Probleme

Der Drucker steht in meiner Werkstatt. Zurzeit beträgt die Raumtemperatur 14°C, was relativ kühl ist. Durch das Heated-Bed-Problem verschärft sich die Situation massiv. Durch diese Umstände habe ich das Problem, dass das Druckobjekt nicht gut genug auf der Platte klebt. Ich habe es mit diversen "Tricks" und deren Kombinationen versucht. So zum Beispiel:

* Blaues Malerabdeckband
* Haarspray
* Fixierspray für Zeichnungen
* Vorheizen mit Heissluftpistole (heizt zwar super, kühlt aber auch schnell wieder aus)

Leider funktioniert keiner dieser Tricks perfekt, solange das Heated-Bed kalt bleibt/wird.

### Upgrades

Da alles Opensource ist und dieser Drucker definitiv zum Weiterentwickeln ausgelegt ist, habe ich auch nach der selbst hergestellten Filament-Spulenhalterung noch weitere Projektideen für Druckerbestandteile. Diese werde ich hier auf der Seite jeweils auch dokumentieren:

* Webcam Halterung
* Smart LCD Controller Case
* Einbau eines Relais, damit das eingebaute Arduino die 12V Versorgung selbst ein- und ausschalten kann
* Eine neue "Arduino mit RAMPS" Halterung (die alte habe ich unabsichtlich zerstört)

### Eingesetzte Software

Ich habe mich für Opensource entschieden, wenn es um die Software geht. Dafür setze ich, als Slicer [slic3r](http://slic3r.org/) ein und sende den [G-Code](https://rc.oxi.ch/index.php/G-Code) dann direkt zu [Octoprint](http://octoprint.org/), welches auf einem [Raspberry Pi 2](https://www.raspberrypi.org/) läuft.

### Opensource

Als Verfechter der Opensource-Bewegung, freue ich mich natürlich besonders, dass es wirklich möglich ist, alles komplett mit Opensource Soft- und Hardware zu betreiben:

* [Kossel](http://reprap.org/wiki/Kossel) XL
* [Marlin Firmware](https://github.com/MarlinFirmware/Marlin) auf einem [Arduino Mega 2560](https://www.arduino.cc/)
* [RAMPS 1.4 EFB](http://reprap.org/wiki/RAMPS_1.4)
* [Smart LCD Controller](http://reprap.org/wiki/RepRapDiscount_Smart_Controller)
* [Octoprint (Octopi)](http://octoprint.org/download/)
* [slic3r](http://slic3r.org/)

### Erste Verwendungen

Als erstes habe ich diverse kleine und einfache Objekte von [Thingiverse](https://www.thingiverse.com) gedruckt. Die hatten keinen konkreten Sinn und Zweck, machten aber richtig Spass.

Das erste kleine Projekt, welches ich selber entwarf und dann produzierte, ist eine Schranktürgriff-Montage. Dieses musste nachgebildet werden, da das Original abgebrochen war. Bis jetzt funktioniert das Ersatzteil super, wird wohl aber irgendwann brechen, da es an gewissen Stellen zu dünn wurde. Version 2 ist schon in Planung.

Stay tuned für weitere Artikel zu meinem Kossel XL und allgemein dem Thema 3D Drucker!
