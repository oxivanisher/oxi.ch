---
title: Hallo Hugo
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
Erneut habe ich meine Website auf ein neues System migriert. Wie immer in der Hoffnung, den administrativen Aufwand zu minimieren. Dieses mal geht es wieder zurück zu einem "Static site generator" welcher [Hugo](https://gohugo.io) heisst.

Im Gegensatz zum vorigen CMS Wordpress, werden die Webseiten nicht be jedem Aufruf neu gerendert, sondern die Website wird bei Änderungen als ganzes Kompiliert und bereitgestellt. Dies macht Websites viel schneller und sicherer und da ich die dynamischen Vorteile von Wordpress sowieso nicht verwendet habe, verliere ich auch keine Funktionalität.

Der ganze "Code" der Website ist in diesem [Github Repository](https://github.com/oxivanisher/oxi.ch) abgelegt und wenn ich Änderungen daran vornehme, wird dies mit Hilfe von [Github Actions](https://github.com/features/actions) automatisch bereitgestellt.

Ich habe alle bestehenden Posts aus Wordpress exportiert und zu Hugo konvertiert. Es gibt jedoch keine Garantie, dass der hinterste und letze Link noch funktioniert. 😊

Dies war der erste [Blogbeitrag im alten Wordpress](/posts/2016-01-25-move-to-wordpress/) über die Migration von Phrozn zu Wordpress. How the Turntables...
