---
title: Hallo Hugo
subtitle: Website migriert von Wordpress zu Hugo
header_img: "img/it-header.jpg"
comment: false
toc: false
draft: false
hide_thumbnail: true
author: oxi
type: post
date: "2023-03-21"
lang: de
categories:
  - Blog
tags:
  - Hosting
  - Deutsch
  - Development
series: []
---
Nach sieben Jahren habe ich meine Website auf ein neues System migriert, um den administrativen Aufwand zu minimieren. Diesmal geht es wieder zurück zu einem Static site generator, welcher [Hugo](https://gohugo.io) heisst.

Im Gegensatz zum vorher verwendeten CMS [Wordpress](https://wordpress.org/download/), werden die Webseiten nicht bei jedem Aufruf neu berechnet, sondern bei dessen Änderungen als Ganzes einmal berechnet und komplett bereitgestellt. Dies macht Websites schneller, energiesparender und sicherer. Da ich die dynamischen Vorteile von Wordpress sowieso nicht verwendet habe, verliere ich dadurch auch keine Funktionalität.

Der ganze Code der Website ist in diesem [Github Repository](https://github.com/oxivanisher/oxi.ch) abgelegt. Wenn ich darin Änderungen hochlade, dann wird dies mittels [Github Actions](https://github.com/features/actions) automatisch bereitgestellt. Wie man das einrichtet, ist auf [dieser Seite von Hugo in englisch beschrieben](https://gohugo.io/hosting-and-deployment/hosting-on-github/).

Ich habe alle bestehenden Posts der letzten sieben Jahre aus Wordpress exportiert und zu Hugo konvertiert. Es gibt keine Garantie, dass alle Links noch funktionieren. 😊

Dies war der erste [Blogbeitrag im alten Wordpress](/posts/2016-01-25-move-to-wordpress/) vor sieben Jahren über die Migration von Phrozn zu Wordpress. How the Turntables…
