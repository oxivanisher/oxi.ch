---
title: Hallo Hugo
subtitle: Website migriert von Wordpress zu Hugo
header_img: "img/it-header.jpg"
comment: false
toc: false
draft: false
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
Nach sieben Jahren habe ich meine Website auf ein neues System migriert. Wie immer in der Hoffnung, den administrativen Aufwand zu minimieren. Dieses mal geht es wieder zurück zu einem "Static site generator", welcher [Hugo](https://gohugo.io) heisst.

Im Gegensatz zum vorigen CMS [Wordpress](https://wordpress.org/download/), werden die Webseiten nicht be jedem Aufruf neu berechnet, sondern die Website wird bei Änderungen als ganzes einmal berechnet und komplett bereitgestellt. Dies macht Websites schneller, energiesparender und sicherer. Da ich die dynamischen Vorteile von Wordpress sowieso nicht verwendet habe, verliere ich dadurch auch keine Funktionalität.

Der ganze Code der Website ist in diesem [Github Repository](https://github.com/oxivanisher/oxi.ch) abgelegt und wenn ich Änderungen daran hochlade, wird dies mit Hilfe von [Github Actions](https://github.com/features/actions) automatisch bereitgestellt. Wie man das einrichtet is auf [dieser Seite von Hugo in englisch beschrieben](https://gohugo.io/hosting-and-deployment/hosting-on-github/).

Ich habe alle bestehenden Posts der letzten sieben Jahre aus Wordpress exportiert und zu Hugo konvertiert. Es gibt keine Garantie, dass alle Links noch funktioniert. 😊

Dies war der erste [Blogbeitrag im alten Wordpress](/posts/2016-01-25-move-to-wordpress/) vor sieben Jahren über die Migration von Phrozn zu Wordpress. How the Turntables...
